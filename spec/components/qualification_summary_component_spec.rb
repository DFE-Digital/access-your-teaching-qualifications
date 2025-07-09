require "rails_helper"

RSpec.describe QualificationSummaryComponent, test: :with_fake_quals_data, type: :component do
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
        awarded_at: fake_quals_data.routes_to_professional_statuses.first.holds_from.to_date,
        type: :rtps,
        details: QualificationsApi::CoercedDetails.new(fake_quals_data.routes_to_professional_statuses.first)
      )
    end
    let(:component) { described_class.new(qualification:) }
    let(:rendered) { render_inline(component) }
    let(:rows) { rendered.css(".govuk-summary-list__row") }

    it "renders the qualification name" do
      expect(rendered.css("h2").text).to eq(qualification.name)
    end

    it "renders the qualification" do
      expect(rows[0].text).to include("Initial teacher training (ITT)")
      expect(rows[1].text).to include("BA")
      expect(rows[2].text).to include("Earl Spencer Primary School")
      expect(rows[3].text).to include("Business Studies")
      expect(rows[4].text).to include("28 February 2022")
      expect(rows[5].text).to include("28 January 2023")
      expect(rows[6].text).to include("In training")
      expect(rows[7].text).to include("7 to 14 years")
    end

    it "omits rows with no value" do
      qualification.details.training_end_date = nil
      qualification.details.status = nil
      expect(rows.text).not_to include("End date")
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
        awarded_at: fake_quals_data.qts.holds_from&.to_date,
        name: "QTS",
        passed_induction: true,
        qtls_only: false,
        qts_and_qtls: false,
        set_membership_active: false,
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
      expect(rows[1].text).to include("Certificate")
    end
  end

  describe "rendering QTLS with Set membership active" do
    let(:fake_quals_data) do
      Hashie::Mash.new(
        quals_data(trn: "1234567")
          .deep_transform_keys(&:to_s)
          .deep_transform_keys(&:underscore)
      )
    end
    let(:qualification) do
      Qualification.new(
        awarded_at: fake_quals_data.qts.holds_from&.to_date,
        name: "QTS",
        passed_induction: true,
        qtls_only: true,
        qts_and_qtls: false,
        set_membership_active: true,
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
      expect(rows[0].text).to include(
        "#{qualification.awarded_at.to_fs(:long_uk)} via qualified teacher learning and skills (QTLS) status"
        )
    end

    it "renders the certificate link" do
      expect(rows[1].text).to include("Download")
    end
  end

  describe "rendering QTLS with Set membership expired" do
    let(:fake_quals_data) do
      Hashie::Mash.new(
        quals_data(trn: "1234567")
          .deep_transform_keys(&:to_s)
          .deep_transform_keys(&:underscore)
      )
    end
    let(:qualification) do
      Qualification.new(
        awarded_at: fake_quals_data.qts.holds_from&.to_date,
        name: "QTS",
        passed_induction: true,
        qtls_only: true,
        qts_and_qtls: false,
        set_membership_active: false,
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
      expect(rows[0].text).to include("No QTS")
    end
  end

  describe "rendering QTS with QTLS" do
    let(:fake_quals_data) do
      Hashie::Mash.new(
        quals_data(trn: "1234567")
          .deep_transform_keys(&:to_s)
          .deep_transform_keys(&:underscore)
      )
    end
    let(:qualification) do
      Qualification.new(
        awarded_at: fake_quals_data.qts.holds_from&.to_date,
        name: "QTS",
        passed_induction: false,
        qtls_only: true,
        qts_and_qtls: false,
        set_membership_active: true,
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

    it "renders the certificate link" do
      expect(rows[1].text).to include("Download QTS certificate")
    end
  end

  describe "rendering QTLS with Set membership active" do
    let(:fake_quals_data) do
      Hashie::Mash.new(
        quals_data(trn: "1234567")
          .deep_transform_keys(&:to_s)
          .deep_transform_keys(&:underscore)
      )
    end
    let(:qualification) do
      Qualification.new(
        awarded_at: fake_quals_data.qts.holds_from&.to_date,
        name: "QTS",
        passed_induction: true,
        qtls_only: true,
        set_membership_active: true,
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
      expect(rows[0].text).to include(
        "#{qualification.awarded_at.to_fs(:long_uk)} via qualified teacher learning and skills (QTLS) status"
        )
    end

    it "renders the certificate link" do
      expect(rows[1].text).to include("Download")
    end
  end

  describe "rendering QTLS with Set membership expired" do
    let(:fake_quals_data) do
      Hashie::Mash.new(
        quals_data(trn: "1234567")
          .deep_transform_keys(&:to_s)
          .deep_transform_keys(&:underscore)
      )
    end
    let(:qualification) do
      Qualification.new(
        awarded_at: fake_quals_data.qts.holds_from&.to_date,
        name: "QTS",
        passed_induction: true,
        qtls_only: true,
        set_membership_active: false,
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
      expect(rows[0].text).to include("No QTS")
    end
  end

  describe "rendering QTS with QTLS" do
    let(:fake_quals_data) do
      Hashie::Mash.new(
        quals_data(trn: "1234567")
          .deep_transform_keys(&:to_s)
          .deep_transform_keys(&:underscore)
      )
    end
    let(:qualification) do
      Qualification.new(
        awarded_at: fake_quals_data.qts.holds_from&.to_date,
        name: "QTS",
        passed_induction: false,
        qtls_only: true,
        set_membership_active: true,
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

    it "renders the certificate link" do
      expect(rows[1].text).to include("Download QTS certificate")
    end
  end
end
