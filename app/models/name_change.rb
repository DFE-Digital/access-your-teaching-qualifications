class NameChange < ApplicationRecord
  belongs_to :user
  has_one_attached :evidence

  def expiring_evidence_url
    evidence.url(expires_in: 5.minutes.in_seconds)
  end

  def evidence_filename
    evidence.filename
  end

  def full_name
    "#{first_name} #{middle_name} #{last_name}".squish
  end
end
