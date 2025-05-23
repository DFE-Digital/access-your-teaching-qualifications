require 'csv'

class BulkSearch
  include ActiveModel::Model

  attr_accessor :file

  validates :file, presence: true
  validate :header_row_present?, if: -> { file.present? }
  validate :all_rows_have_data, if: -> { file.present? }
  validate :row_limit_not_exceeded, if: -> { file.present? }

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
    @csv ||= CSV.parse(file.read, headers: true)
  end

  private

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
    trn.to_s.rjust(7, '0')
  end
end