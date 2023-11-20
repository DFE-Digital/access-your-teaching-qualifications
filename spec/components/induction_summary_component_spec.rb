require "rails_helper"

RSpec.describe InductionSummaryComponent, test: :with_fake_quals_data, type: :component do
  describe "rendering" do
    subject(:rendered) { render_inline(component) }

    let(:fake_quals_data) do
      Hashie::Mash.new(
        quals_data(trn: "1234567")
          .deep_transform_keys(&:to_s)
          .deep_transform_keys(&:underscore)
      )
    end
    let(:induction) { fake_quals_data.fetch("induction") }
    let(:qualification) do
      Qualification.new(
        name: "Induction summary",
        awarded_at: induction.end_date&.to_date,
        type: :itt,
        details: induction
      )
    end
    let(:component) { described_class.new(qualification:) }

    it "renders the component title" do
      expect(rendered.css(".govuk-summary-card__title").text).to eq("Induction summary")
    end

    it "renders the component rows" do
      rows = rendered.css(".govuk-summary-list__row")
      expect(rows[0].css(".govuk-summary-list__key").text).to eq("Status")
      expect(rows[0].css(".govuk-summary-list__value").text).to eq("Pass")

      expect(rows[1].css(".govuk-summary-list__key").text).to eq("Completed")
      expect(rows[1].css(".govuk-summary-list__value").text).to eq(" 1 October 2022")

      expect(rows[2].css(".govuk-summary-list__key").text).to eq("Certificate")
      expect(rows[2].css(".govuk-summary-list__value").text).to eq("Download Induction certificate")

      expect(rows[3].css(".govuk-summary-list__key").text).to eq("Appropriate body")
      expect(rows[3].css(".govuk-summary-list__value").text).to eq("Induction body")

      expect(rows[4].css(".govuk-summary-list__key").text).to eq("Start date")
      expect(rows[4].css(".govuk-summary-list__value").text).to eq(" 1 September 2022")

      expect(rows[5].css(".govuk-summary-list__key").text).to eq("End date")
      expect(rows[5].css(".govuk-summary-list__value").text).to eq(" 1 October 2022")

      expect(rows[6].css(".govuk-summary-list__key").text).to eq("Number of terms")
      expect(rows[6].css(".govuk-summary-list__value").text).to eq("1")
    end

    it "renders does not render empty component rows" do
      component.qualification.awarded_at = nil
      component.qualification.details.periods.first.end_date = nil

      expect(rendered.css(".govuk-summary-list__key").map(&:text)).not_to include("Completed")
      expect(rendered.css(".govuk-summary-list__key").map(&:text)).not_to include("End date")
    end

    context "when the certificate URL is missing" do
      let(:induction) do
        fake_quals_data.fetch("induction").tap do |data|
          data.delete(:certificate_url)
        end
      end

      it "does not render the certificate row when certificate URL is missing" do
        expect(rendered.css(".govuk-summary-list__key").map(&:text)).not_to include("Certificate")
      end
    end
  end
end
