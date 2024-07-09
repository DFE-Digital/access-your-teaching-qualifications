class DateOfBirthChange < ApplicationRecord
  belongs_to :user
  has_one_attached :evidence

  delegate :filename, to: :evidence, prefix: true

  enum malware_scan_result: {
    clean: "clean",
    error: "error",
    pending: "pending",
    suspect: "suspect"
  }, _prefix: :scan_result


  def expiring_evidence_url
    evidence.url(expires_in: 5.minutes.in_seconds)
  end

  def malware_scan
    return unless evidence.attached?

    FetchMalwareScanResultJob.set(wait: 30.seconds).perform_later(change_request: self)
  end
end
