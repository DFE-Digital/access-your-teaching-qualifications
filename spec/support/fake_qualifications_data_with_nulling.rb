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

    minimal_induction!
    minimal_rtps!
    minimal_mandatory_qualifications!
    minimal_sanctions!
    @data
  end

  private

  def minimal_induction!
    @data[:induction][:startDate] = nil
    @data[:induction][:endDate] = nil
    @data[:induction][:status] = "None"
    @data[:induction][:certificateUrl] = nil
  end

  def minimal_rtps!
    @data[:routesToProfessionalStatuses].each do |rtps|
      rtps[:trainingEndDate] = nil
      rtps[:trainingStartDate] = nil
      rtps[:holdsFrom] = nil
    end
  end

  def minimal_mandatory_qualifications!
    @data
  end

  def minimal_sanctions!
    @data[:alerts] = [ { alert_type: { alert_type_id: "40794ea8-eda2-40a8-a26a-5f447aae6c99"}, startDate: nil } ]
  end
end
