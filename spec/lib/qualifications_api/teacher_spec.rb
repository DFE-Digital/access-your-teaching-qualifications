require "rails_helper"

RSpec.describe QualificationsApi::Teacher, type: :model do
  let(:api_data) do
    {
      "trn" => "1111111",
      "induction" => {
        "startDate" => "2015-01-01",
        "endDate" => "2015-07-01",
        "status" => "Complete",
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
            "name" => "PGCE"
          },
          "startDate" => "2011-01-17",
          "endDate" => "2012-02-2",
          "programmeType" => "EYITTSchoolDirectEarlyYears",
          "programmeTypeDescription" => "Early Years Initial Teacher Training (School Direct)",
          "result" => "Passed",
          "ageRange" => {
            "description" => "3 to 7 years"
          },
          "provider" => {
            "name" => "Earl Spencer Primary School",
            "ukprn" => nil
          },
          "subjects" => [{ "code" => "100079", "name" => "business studies" }]
        },
        {
          "qualification" => {
            "name" => "BA"
          },
          "startDate" => "2012-02-28",
          "endDate" => "2013-01-28",
          "programmeType" => "HEI",
          "programmeTypeDescription" => "Higher Education Institution",
          "result" => "Passed",
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
        "awarded" => "2015-11-01",
        "statusDescription" => "Qualified (trained in the UK)",
      },
      "eyts" => {
        "awarded" => "2015-11-02",
        "certificateUrl" => "https://example.com/certificate.pdf",
        "statusDescription" => "Qualified",
      },
      "mandatoryQualifications" => [
        { "endDate" => "2013-06-01", "specialism" => "Visual Impairment", "qualificationId" => 1 }
      ],
    }
  end

  describe "#qualifications" do
    subject(:qualifications) { teacher.qualifications }

    let(:teacher) { described_class.new(api_data) }

    it "sorts the qualifications in reverse chronological order by date of award" do
      expect(qualifications.map(&:type)).to eq(
        %i[NPQSL NPQML mandatory induction qts itt eyts itt]
      )
    end

    it "orders QTS ITT qualifications before EYTS ITT qualifications" do
      itt_qualifications = qualifications.select { |q| q.type == :itt }
      expect(itt_qualifications.map { |q| q.details.programme_type }).to eq(
        %w[HEI EYITTSchoolDirectEarlyYears]
      )
    end

    it "designates ITT qualifications as QTS if no programme type is present" do
      itt_qualification = api_data["initialTeacherTraining"].first
      itt_qualification["programmeType"] = nil
      api_data["initialTeacherTraining"] = [itt_qualification]

      expect(qualifications.map(&:type)).to eq(
        %i[NPQSL NPQML mandatory induction qts itt eyts]
      )
    end

    context "ITT result field" do
      before do
        api_data["initialTeacherTraining"].each { |itt| itt["result"] = "DeferredForSkillsTests" }
      end

      it "returns human readable values" do
        expect(qualifications.find { |q| q.type == :itt }.details.result).to eq("Deferred for skills tests")
      end
    end

    context "when a qualification has no awarded date" do
      let(:api_data) do
        {
          "trn" => "111112",
          "initial_teacher_training" => [
            {
              "qualification" => {
                "name" => "BA"
              },
              "startDate" => "2012-02-28",
              "endDate" => "2013-01-28",
              "programmeType" => "HEI",
              "programmeTypeDescription" => "Higher Education Institution",
              "result" => "Passed",
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

      it "sorts the qualifications in reverse order by date of award and type" do
        expect(qualifications.map(&:type)).to eq(%i[NPQML itt])
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
              "result" => "Passed",
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
            "awarded" => "2013-01-28",
          }
        }
      end

      it "the QTS gets priority in the sort order" do
        expect(qualifications.map(&:type)).to eq(%i[qts itt])
      end
    end

    context "when programmeType is an Integer" do
      let(:api_data) do
        {
          "initialTeacherTraining" => [
            {
              "qualification" => {
                "name" => "BA"
              },
              "startDate" => "2012-02-28",
              "endDate" => "2013-01-28",
              "programmeType" => 1,
              "programmeTypeDescription" => "Higher Education Institution",
              "result" => "Passed",
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
            "awarded" => "2013-01-28",
          }
        }
      end

      it "the QTS gets priority in the sort order" do
        expect(qualifications.map(&:type)).to eq(%i[qts itt])
      end
    end
  end

  describe "#name" do
    let(:api_data) do
      {
        "firstName" => "Jane",
        "middleName" => "Smith",
        "lastName" => "Jones"
      }
    end
    let(:teacher) { described_class.new(api_data) }

    it "returns the full name" do
      expect(teacher.name).to eq("Jane Smith Jones")
    end
  end

  describe "#previous_names" do
    let(:api_data) do
      {
        "firstName" => "Jane",
        "middleName" => "Smith",
        "lastName" => "Jones",
        "previousNames" => [
          {
            "firstName" => "John",
            "middleName" => "Smith",
            "lastName" => "DOE",
          },
          {
            "firstName" => "Johan",
            "middleName" => "Smith",
            "lastName" => "DoE",
          },
          {
            "firstName" => "Johan",
            "middleName" => "Smith",
            "lastName" => "Johnson",
          },
          {
            "firstName" => "Johan",
            "middleName" => "Smith",
            "lastName" => nil,
          },
          {
            "firstName" => "Jim",
            "middleName" => "Smith",
            "lastName" => "JONES",
          },
        ]
      }
    end
    let(:teacher) { described_class.new(api_data) }

    it "returns an array of previous names" do
      expect(teacher.previous_names).to eq(
        %w[Doe Johnson]
      )
    end

    context "when there are no previous names" do
      let(:api_data) do
        {
          "firstName" => "Jane",
          "middleName" => "Smith",
          "lastName" => "Jones",
          "previousNames" => []
        }
      end

      it "returns an empty array" do
        expect(teacher.previous_names).to eq([])
      end
    end
  end

  describe "qts_awarded?" do
    let(:teacher) { described_class.new(api_data) }

    context "qts awarded timestamp is present" do
      let(:api_data) { { "qts" => { "awarded" => "2013-01-28", } } }

      it "returns true" do
        expect(teacher.qts_awarded?).to eq true
      end
    end

    context "qts awarded timestamp is blank" do
      let(:api_data) { { "qts" => {} } }

      it "returns false" do
        expect(teacher.qts_awarded?).to eq false
      end
    end
  end

  describe "passed_induction?" do
    let(:teacher) { described_class.new(api_data) }

    context "induction status is 'Pass'" do
      let(:api_data) { { "induction" => { "status" => "Passed", } } }

      it "returns true" do
        expect(teacher.passed_induction?).to eq true
      end
    end

    context "induction status is anything other than 'Pass'" do
      let(:api_data) { { "induction" => { "status_description" => "Failed", } } }

      it "returns false" do
        expect(teacher.passed_induction?).to eq false
      end
    end

    context "induction status is blank" do
      let(:api_data) { { "induction" => {} } }

      it "returns false" do
        expect(teacher.passed_induction?).to eq false
      end
    end
  end

  describe "#pending_name_change?" do
    let(:teacher) { described_class.new(api_data) }

    context "pendingNameChange field is false" do
      let(:api_data) { { "pendingNameChange" => false } }

      it "returns false" do
        expect(teacher.pending_name_change?).to eq false
      end
    end

    context "pendingNameChange field is true" do
      let(:api_data) { { "pendingNameChange" => true } }

      it "returns true" do
        expect(teacher.pending_name_change?).to eq true
      end
    end
  end

  describe "#pending_date_of_birth_change?" do
    let(:teacher) { described_class.new(api_data) }

    context "pendingDateOfBirthChange field is false" do
      let(:api_data) { { "pendingDateOfBirthChange" => false } }

      it "returns false" do
        expect(teacher.pending_date_of_birth_change?).to eq false
      end
    end

    context "pendingDateOfBirthChange field is true" do
      let(:api_data) { { "pendingDateOfBirthChange" => true } }

      it "returns true" do
        expect(teacher.pending_date_of_birth_change?).to eq true
      end
    end
  end

  describe '#no_restrictions?' do
    subject(:no_restrictions) { teacher.no_restrictions? }

    let(:teacher) { described_class.new(api_data) }

    it { is_expected.to be_truthy }

    context "when there are sanctions that are not prohibited" do
      let(:api_data) do
        {
          "alerts" => [
            "alert_type" => {
              "alert_type_id" => "7924fe90-483c-49f8-84fc-674feddba848"
            }, 
            "start_date" => "2024-01-01" 
          ]
        }
      end

      it { is_expected.to be_truthy }
    end

    context "when there are sanctions not listed in the Sanction model" do
      let(:api_data) do
        {
          "alerts" => [
            "alert_type" => {
            "alert_type_id" => "Nonsense", "start_date" => "2024-01-01" 
          },
          ]
        }
      end

      it { is_expected.to be_truthy }
    end

    context "when there are sanctions that are prohibited" do
      let(:api_data) do
        {
          "alerts" => [
            "alert_type" =>  {
              "alert_type_id" => "1a2b06ae-7e9f-4761-b95d-397ca5da4b13"
            },
            "start_date" => "2024-01-01" 
          ]
        }
      end

      it { is_expected.to be_falsey }
    end

    context "when there are sanctions that have an end date" do
      let(:api_data) do
        {
          "alerts" => [
            "alert_type" =>  {
              "alert_type_id" => "1a2b06ae-7e9f-4761-b95d-397ca5da4b13"
            },
            "start_date" => "2024-01-01",
            "end_date" => "2025-01-02",
          ]
        }
      end

      it { is_expected.to be_truthy }
    end
  end
end
