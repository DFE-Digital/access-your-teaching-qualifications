require "rails_helper"

RSpec.describe QualificationsApi::Teacher, type: :model do
  describe "#qualifications" do
    subject(:qualifications) { teacher.qualifications }

    let(:api_data) do
      {
        "induction" => {
          "startDate" => "2015-01-01",
          "endDate" => "2015-07-01",
          "status" => "complete",
          "certificateUrl" => "https",
          "periods" => [
            {
              "startDate" => "string",
              "endDate" => "string",
              "terms" => "integer",
              "appropriateBody" => {
                "name" => "string"
              }
            }
          ]
        },
        "initialTeacherTraining" => [
          {
            "qualification" => {
              "name" => "BA"
            },
            "startDate" => "2012-02-28",
            "endDate" => "2013-01-28",
            "programmeType" => "HEI",
            "programmeTypeDescription" => "Higher Education Institution",
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
        "mandatoryQualifications" => [
          { "awarded" => "2013-06-01", "specialism" => "Visual Impairment" }
        ],
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
      expect(qualifications.map(&:type)).to eq(
        %i[NPQSL NPQML eyts qts induction mandatory itt]
      )
    end

    context "when a qualification has no awarded date" do
      let(:api_data) do
        {
          "initial_teacher_training" => [
            {
              "qualification" => {
                "name" => "BA"
              },
              "startDate" => "2012-02-28",
              "endDate" => "2013-01-28",
              "programmeType" => "HEI",
              "programmeTypeDescription" => "Higher Education Institution",
              "result" => "Pass",
              "ageRange" => {
                "description" => "10 to 16 years"
              },
              "provider" => {
                "name" => "Earl Spencer Primary School",
                "ukprn" => nil
              },
              "subjects" => [
                { "code" => "100079", "name" => "business studies" }
              ]
            }
          ],
          "npqQualifications" => [
            {
              "type" => {
                "code" => "NPQML",
                "name" => "NPQ for Middle Leadership"
              },
              "awarded" => nil,
              "certificateUrl" => "https://example.com/v3/certificates/456"
            }
          ]
        }
      end

      it "sorts the qualifications in reverse chronological order by date of award" do
        expect(qualifications.map(&:type)).to eq(%i[itt NPQML])
      end
    end

    context "when there are no MQs returned" do
      let(:api_data) { {} }

      it "returns an empty array" do
        expect(qualifications).to eq([])
      end
    end

    context "when QTS and ITT share the same date" do
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
              "programmeTypeDescription" => "Higher Education Institution",
              "result" => "Pass",
              "ageRange" => {
                "description" => "10 to 16 years"
              },
              "provider" => {
                "name" => "Earl Spencer Primary School",
                "ukprn" => nil
              },
              "subjects" => [
                { "code" => "100079", "name" => "business studies" }
              ]
            }
          ],
          "qts" => {
            "awarded" => "2013-01-28"
          }
        }
      end

      it "the QTS gets priority in the sort order" do
        expect(qualifications.map(&:type)).to eq(%i[qts itt])
      end
    end

    context "when a Higher Education qualification is returned" do
      let(:api_data) do
        {
          "higherEducationQualifications" => [
            {
              "name" => "Some Qualification",
              "awarded" => "2022-2-22",
              "subjects" => [
                { "code" => "100079", "name" => "Business Studies" }
              ]
            }
          ]
        }
      end

      it "creates a qualification with the correct attributes" do
        expect(qualifications.first).to have_attributes(
          type: :higher_education,
          name: "Some Qualification",
          awarded_at: Date.parse("2022-2-22")
        )
      end
    end
  end
end
