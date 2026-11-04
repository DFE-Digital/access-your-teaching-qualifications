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
        awarded_at: induction.completed_date&.to_date,
        type: :induction,
        qtls_only: false,
        qts_and_qtls: false,
        set_membership_active: false,
        induction_status: :passed,
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
      expect(rows[0].css(".govuk-summary-list__value").text).to eq("Passed")

      expect(rows[1].css(".govuk-summary-list__key").text).to eq("Completed")
      expect(rows[1].css(".govuk-summary-list__value").text).to eq(" 1 October 2022")

      expect(rows[2].css(".govuk-summary-list__key").text).to eq("Certificate")
      expect(rows[2].css(".govuk-summary-list__value").text).to eq("Download Induction certificate")
    end

    it "renders does not render empty component rows" do
      component.qualification.awarded_at = nil

      expect(rendered.css(".govuk-summary-list__key").map(&:text)).not_to include("Completed")
      expect(rendered.css(".govuk-summary-list__key").map(&:text)).not_to include("End date")
    end
  end

  describe "QTLS membership messages" do
    subject(:rendered) { render_inline(described_class.new(qualification:)) }

    let(:qualification) do
      Qualification.new(
        name: "Induction summary",
        type: :induction,
        induction_status:,
        set_membership_active: membership_active,
        set_membership_expired: !membership_active,
      )
    end

    context "when QTLS membership is active" do
      let(:membership_active) { true }
      let(:induction_status) { :exempt }

      it "reminds the teacher that the induction exemption depends on QTLS membership" do
        expect(rendered.text).to include(
          "You will no longer be exempt from induction if your " \
          "Society for Education and Training (SET) membership expires"
        )
      end
    end

    context "when QTLS membership has expired" do
      let(:membership_active) { false }
      let(:induction_status) { :none }

      it "warns the teacher that the induction exemption ended with their QTLS membership" do
        expect(rendered.text).to include(
          "You are no longer exempt from induction because your " \
          "Society for Education and Training (SET) membership expired"
        )
      end
    end
  end
end
