require 'csv'

class BulkSearch
  include ActiveModel::Model

  attr_accessor :file

  validates :file, presence: true
  validate :header_row_present?, if: -> { file.present? }

  def call
    return false if invalid?

    [total, results]
  end

  def results
    @results ||= csv.map { |row| find_teacher_by(trn: row["TRN"]) }.compact
  end

  def total
    @total ||= results.count
  end

  private

  def csv
    @csv ||= CSV.parse(file.read, headers: true)
  end

  def header_row_present?
    expected_headers = ["Last name", "Date of birth", "TRN"]
    return if csv.headers == expected_headers

    errors.add(:file, "The header row is missing or incorrect")
  end

  def find_teacher_by(trn:)
    search_client.teacher(trn:)
  end

  def search_client
    @search_client ||= QualificationsApi::Client.new(
      token: ENV["QUALIFICATIONS_API_FIXED_TOKEN"]
    )
  end
end