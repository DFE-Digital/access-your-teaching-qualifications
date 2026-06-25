require "csv"

class BulkSearch
  include ActiveModel::Model

  # The whole file is read into memory before anything can inspect it, and the
  # 100-row limit only runs after parsing, so it can't bound that read. A full
  # template is a few KB, so 1MB is generous headroom.
  MAX_SIZE = 1.megabyte
  # Browsers are inconsistent about the Content-Type they declare for CSVs,
  # e.g. Windows machines with Excel installed send application/vnd.ms-excel
  ALLOWED_CONTENT_TYPES = ["text/csv", "application/csv",
                           "application/vnd.ms-excel", "text/plain"].freeze
  attr_accessor :file

  validates :file, presence: true
  validate :validate_file_size, if: -> { file.present? }

  # Each check only runs once everything before it has passed, so a broken
  # file gets the first relevant error rather than a cascade
  with_options if: -> { file.present? && errors.none? } do
    validate :validate_file_type
    validate :validate_file_parses_as_csv
    validate :header_row_present?
    validate :row_limit_not_exceeded
    validate :all_rows_have_data
  end

  def call
    return false if invalid?

    [total, results, not_found]
  end

  def not_found
    @not_found ||= csv.map { |row|
      next if results.any? { |teacher| teacher.trn == sanitise_trn(row["TRN"]) }

      Hashie::Mash.new(trn: sanitise_trn(row["TRN"]), date_of_birth: Date.parse(row["Date of birth"]))
    }.compact
  end

  def results
    @results ||= response.fetch("results", []).map do |teacher|
      QualificationsApi::Teacher.new(teacher)
    end
  end

  def total
    @total ||= response.fetch("total", 0)
  end

  def csv
    @csv ||= CSV.parse(file_content, headers: true)
  end

  private

  def validate_file_size
    return if file.size <= MAX_SIZE

    errors.add(:file, "The selected file must be smaller than 1MB")
  end

  def validate_file_type
    return if raw_content.empty? # empty files get the template error from the header check
    return if ALLOWED_CONTENT_TYPES.include?(file.content_type) &&
      sniffed_type_is_text? && file_content_is_text?

    errors.add(:file, "The selected file must be a CSV")
  end

  # Plain text has no magic bytes, so Marcel can't positively identify a CSV —
  # the most it can do is positively identify a disguised binary (PDF, image,
  # zip), which is what this rejects. Content it can't identify comes back as
  # application/octet-stream and falls through to file_content_is_text?
  def sniffed_type_is_text?
    sniffed_content_type == "application/octet-stream" ||
      sniffed_content_type.start_with?("text/")
  end

  # Following the WHATWG MIME sniffing approach: text contains no NUL bytes,
  # and our template is always UTF-8
  def file_content_is_text?
    file_content.valid_encoding? && !file_content.include?("\0")
  end

  def validate_file_parses_as_csv
    csv
  rescue CSV::MalformedCSVError
    errors.add(:file, "The selected file must be a CSV")
  end

  def all_rows_have_data
    csv.each_with_index do |row, index|
      if row["Date of birth"].blank?
        errors.add(:file, "The selected file does not have a date of birth in row #{index + 1}")
      else
        begin
          Date.parse(row["Date of birth"])
        rescue Date::Error
          errors.add(
            :file,
            "The date of birth in row #{index + 1} must be in DD/MM/YYYY format"
          )
        end
      end

      if row["TRN"].blank?
        errors.add(:file, "The selected file does not have a TRN in row #{index + 1}")
      end
    end
  end

  def header_row_present?
    expected_headers = ["TRN", "Date of birth"]
    return if csv.headers == expected_headers

    errors.add(:file, "The selected file must use the template")
  end

  def find_all(queries)
    search_client.bulk_teachers(queries:) || {}
  end

  def raw_content
    @raw_content ||= begin
      file.rewind
      file.read
    end
  end

  def sniffed_content_type
    # Sniff from the raw bytes so detection ignores the client-supplied
    # filename and Content-Type header
    Marcel::MimeType.for(StringIO.new(raw_content))
  end

  # Excel exports UTF-8 CSVs with a leading byte order mark, which would
  # otherwise corrupt the first header and fail the template check
  def file_content
    @file_content ||= raw_content.dup.force_encoding(Encoding::UTF_8).delete_prefix("\uFEFF")
  end

  def response
    @response ||= begin
      queries = csv.map { |row|
 { trn: sanitise_trn(row["TRN"]), dateOfBirth: Date.parse(row["Date of birth"]) } }.compact
      find_all(queries)
    end
  end

  def row_limit_not_exceeded
    return if csv.count <= 100

    errors.add(:file, "The selected file must have 100 or fewer rows")
  end

  def search_client
    @search_client ||= QualificationsApi::Client.new(
      token: ENV["QUALIFICATIONS_API_FIXED_TOKEN"]
    )
  end

  def sanitise_trn(trn)
    # Ensure the TRN is exactly 7 characters by padding with leading zeros, csv formatting can remove leading zeros
    trn.to_s.rjust(7, "0")
  end
end
