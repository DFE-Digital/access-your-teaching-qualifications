class NameChange < ApplicationRecord
  belongs_to :user
  has_one_attached :evidence

  def expiring_evidence_url
    evidence.url(expires_in: 5.minutes.in_seconds)
  end

  delegate :filename, to: :evidence, prefix: true

  def full_name
    "#{first_name} #{middle_name} #{last_name}".squish
  end
end
