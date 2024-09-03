require 'csv'

class BulkSearch
  include ActiveModel::Model

  attr_accessor :file

  validates :file, presence: true
  validate :header_row_present?, if: -> { file.present? }
  validate :all_rows_have_data, if: -> { file.present? }

  def call
    return false if invalid?

    [total, results, not_found]
  end

  def not_found
    @not_found ||= csv.map { |row|
      next if results.any? { |teacher| teacher.trn == row["TRN"] }

      Hashie::Mash.new(trn: row["TRN"], date_of_birth: Date.parse(row["Date of birth"]))
    }.compact
  end

  def results
    @results ||= response["results"].map do |teacher|
      QualificationsApi::Teacher.new(teacher)
    end
  end

  def total
    @total ||= response["total"]
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
    search_client.bulk_teachers(queries:)
  end

  def response
    @response ||= begin
      queries = csv.map { |row| { trn: row["TRN"], dateOfBirth: row["Date of birth"] } }.compact
      find_all(queries)
    end
  end

  def search_client
    @search_client ||= QualificationsApi::Client.new(
      token: ENV["QUALIFICATIONS_API_FIXED_TOKEN"]
    )
  end
end