require "rails_helper"

RSpec.describe QualificationsApi::Teacher, type: :model do
  describe "#qualifications" do
    subject(:qualifications) { teacher.qualifications }

    let(:api_data) do
      {
        "initialTeacherTraining" => [
          {
            "qualification" => {
              "name" => "BA"
            },
            "startDate" => "2012-02-28",
            "endDate" => "2013-01-28",
            "programmeType" => "HEI",
            "result" => "Pass",
            "ageRange" => {
              "description" => "10 to 16 years"
            },
            "provider" => {
              "name" => "Earl Spencer Primary School",
              "ukprn" => nil
            },
            "subjects" => [{ "code" => "100079", "name" => "business studies" }]
          }
        ],
        "qts" => {
          "awarded" => "2015-11-01"
        },
        "eyts" => {
          "awarded" => "2015-11-02",
          "certificateUrl" => "https://example.com/certificate.pdf"
        },
        "npqQualifications" => [
          {
            "type" => {
              "code" => "NPQML",
              "name" => "NPQ for Middle Leadership"
            },
            "awarded" => "2015-11-03",
            "certificateUrl" => "https://example.com/v3/certificates/456"
          },
          {
            "type" => {
              "code" => "NPQSL",
              "name" => "NPQ for Senior Leadership"
            },
            "awarded" => "2015-11-04",
            "certificateUrl" => "https://example.com/v3/certificates/123"
          }
        ]
      }
    end
    let(:teacher) { described_class.new(api_data) }

    it "sorts the qualifications in reverse chronological order by date of award" do
      expect(qualifications.map(&:type)).to eq(%i[NPQSL NPQML eyts qts itt])
    end
  end
end
