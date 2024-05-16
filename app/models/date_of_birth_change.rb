class DateOfBirthChange < ApplicationRecord
  belongs_to :user
  has_one_attached :evidence

  delegate :filename, to: :evidence, prefix: true

  def expiring_evidence_url
    evidence.url(expires_in: 5.minutes.in_seconds)
  end
end
