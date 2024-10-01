require "rails_helper"

RSpec.describe CheckRecords::QualificationSummaryComponent, test: :with_fake_quals_data, type: :component do
  describe "rendering" do
    let(:fake_quals_data) do
      Hashie::Mash.new(
        quals_data(trn: "1234567")
          .deep_transform_keys(&:to_s)
          .deep_transform_keys(&:underscore)
      )
    end
    let(:qualification) do
      Qualification.new(
        name: "Initial teacher training (ITT)",
        awarded_at: fake_quals_data.end_date&.to_date,
        type: :itt,
        details: fake_quals_data.fetch("initial_teacher_training").first
      )
    end
    let(:component) { described_class.new(qualification:) }
    let(:rendered) { render_inline(component) }
    let(:rows) { rendered.css(".govuk-summary-list__row") }

    it "renders the qualification name" do
      expect(rendered.css("h2").text).to eq(qualification.name)
    end

    it "renders the qualification" do
      expect(rows[0].text).to include(qualification.details.dig(:qualification, :name))
    end

    it "renders the qualification provider" do
      expect(rows[1].text).to include(qualification.details.dig(:provider, :name))
    end

    it "renders the qualification programme type" do
      expect(rows[2].text).to include(qualification.details.programme_type_description)
    end

    it "renders the qualification subject" do
      expect(rows[3].text).to include(qualification.details.subjects.first.name.titleize)
    end

    it "renders the qualification age range" do
      expect(rows[4].text).to include(qualification.details.age_range&.description)
    end

    it "renders the qualification status" do
      expect(rows[5].text).to include(Date.parse(qualification.details.start_date).to_fs(:long_uk))
    end

    it "renders the qualification course end date" do
      expect(rows[6].text).to include(Date.parse(qualification.details.end_date).to_fs(:long_uk))
    end

    it "renders the qualification status" do
      expect(rows[7].text).to include(qualification.details.result)
    end

    it "omits rows with no value" do
      qualification.details.end_date = nil
      qualification.details.result = nil
      expect(rows.text).not_to include("Course end date")
      expect(rows.text).not_to include("Course result")
    end
  end

  describe "rendering QTS" do
    let(:fake_quals_data) do
      Hashie::Mash.new(
        quals_data(trn: "1234567")
          .deep_transform_keys(&:to_s)
          .deep_transform_keys(&:underscore)
      )
    end
    let(:qualification) do
      Qualification.new(
        awarded_at: fake_quals_data.qts.awarded&.to_date,
        name: "QTS",
        status_description: "Qualified (trained in the UK)",
        type: :qts,
      )
    end
    let(:component) { described_class.new(qualification:) }
    let(:rendered) { render_inline(component) }
    let(:rows) { rendered.css(".govuk-summary-list__row") }

    it "renders the qualification name" do
      expect(rendered.css("h2").text).to eq(qualification.name)
    end

    it "renders the awarded at date" do
      expect(rows[0].text).to include(qualification.awarded_at.to_fs(:long_uk))
    end

    it "renders the status description" do
      expect(rows[1].text).to include(qualification.status_description)
    end
  end
end
