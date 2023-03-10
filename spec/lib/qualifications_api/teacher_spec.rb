require "rails_helper"

RSpec.describe QualificationsApi::Teacher, type: :model do
  describe "#qts_date" do
    subject(:qts_date) { teacher.qts_date }

    let(:api_data) { { "qtsDate" => "2015-11-01" } }
    let(:teacher) { described_class.new(api_data) }

    it { is_expected.to eq(Date.new(2015, 11, 1)) }

    context "when the qtsDate is nil" do
      let(:api_data) { { "qtsDate" => nil } }

      it { is_expected.to be_nil }
    end
  end

  describe "#itt" do
    subject(:itt) { teacher.itt }

    let(:api_data) do
      {
        "initialTeacherTraining" => [
          {
            "qualification" => {
              "name" => "BA"
            },
            "startDate" => "2022-02-28",
            "endDate" => "2023-01-28",
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
        ]
      }
    end
    let(:teacher) { described_class.new(api_data) }

    it "returns a qualification name" do
      expect(itt.qualification_name).to eq("BA")
    end

    it "returns a provider name" do
      expect(itt.provider_name).to eq("Earl Spencer Primary School")
    end

    it "returns a programme type" do
      expect(itt.programme_type).to eq("HEI")
    end

    it "returns the subjects" do
      expect(itt.subjects).to eq(["business studies"])
    end

    it "returns the start date" do
      expect(itt.start_date).to eq(Date.new(2022, 2, 28))
    end

    it "returns the end date" do
      expect(itt.end_date).to eq(Date.new(2023, 1, 28))
    end

    it "returns the result" do
      expect(itt.result).to eq("Pass")
    end

    it "returns the age range" do
      expect(itt.age_range).to eq("10 to 16 years")
    end
  end
end
