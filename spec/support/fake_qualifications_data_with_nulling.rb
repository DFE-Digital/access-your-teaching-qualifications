require_relative "fake_qualifications_data"

class FakeQualificationsDataWithNulling
  include FakeQualificationsData

  # This returns an API response with most nullable fields set to nil. Although
  # entire qualification fields are nullable, here we return data for each
  # qualification but with mandatory values only.
  # Reference: https://teacher-qualifications-api.education.gov.uk/swagger/v3.json
  def self.generate
    new.generate
  end

  def generate
    @data = quals_data

    @data[:dateOfBirth] = nil
    @data[:lastName] = nil
    @data[:previousNames] = []

    minimal_eyts!
    minimal_qts!
    minimal_induction!
    minimal_itt!
    minimal_mandatory_qualifications!
    minimal_npq!
    minimal_sanctions!
    @data
  end

  private

  def minimal_eyts!
    @data[:eyts][:certificateUrl] = nil
  end

  def minimal_qts!
    @data[:qts][:certificateUrl] = nil
  end

  def minimal_induction!
    @data[:induction][:startDate] = nil
    @data[:induction][:endDate] = nil
    @data[:induction][:status] = "None"
    @data[:induction][:statusDescription] = nil
    @data[:induction][:certificateUrl] = nil
  end

  def minimal_itt!
    @data[:initialTeacherTraining].each do |itt|
      itt[:qualification] = nil
      itt[:startDate] = nil
      itt[:endDate] = nil
      itt[:programmeType] = nil
      itt[:programmeTypeDescription] = nil
      itt[:result] = nil
      itt[:ageRange] = nil
      itt[:provider] = nil
    end
  end

  def minimal_mandatory_qualifications!
    @data
  end

  def minimal_npq!
    @data[:npqQualifications].each do |npq|
      npq[:certificateUrl] = nil
    end
  end

  def minimal_sanctions!
    @data[:alerts] = [ { alert_type: { alert_type_id: "40794ea8-eda2-40a8-a26a-5f447aae6c99"}, startDate: nil } ]
  end
end
