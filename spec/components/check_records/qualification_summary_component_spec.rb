require "rails_helper"

class CoercedDetails < Hash
  include Hashie::Extensions::Coercion
  include Hashie::Extensions::MergeInitializer
  include Hashie::Extensions::MethodAccess

  coerce_key :result, ->(value) { value.underscore.humanize }
end

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
        name: "Route to QTS",
        awarded_at: fake_quals_data.routes_to_professional_statuses.first.holds_from.to_date,
        type: :qts_rtps,
        details: QualificationsApi::CoercedDetails.new(fake_quals_data.routes_to_professional_statuses.first)
      )
    end
    let(:component) { described_class.new(qualification:) }
    let(:rendered) { render_inline(component) }
    let(:rows) { rendered.css(".govuk-summary-list__row") }

    it "renders the title of the section with the route type" do
      expect(rendered.css("h2").text).to eq("Route to QTS: Initial teacher training (ITT)")
    end

    it "renders the qualification" do
      expect(rows[0].text).to include("BA")
      expect(rows[1].text).to include("Earl Spencer Primary School")
      expect(rows[2].text).to include("Business Studies")
      expect(rows[3].text).to include("7 to 14 years")
      expect(rows[4].text).to include("28 February 2022")
      expect(rows[5].text).to include("28 January 2023")
      expect(rows[6].text).to include("Holds")
    end

    it "omits rows with no value" do
      qualification.details.end_date = nil
      qualification.details.status = nil
      expect(rows.text).not_to include("Course end date")
      expect(rows.text).not_to include("Result")
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
        name: "Qualified teacher status (QTS)",
        qtls_only: false,
        set_membership_active: false,
        passed_induction: false,
        qts_and_qtls: false,
        type: :qts,
      )
    end
    let(:component) { described_class.new(qualification:) }
    let(:rendered) { render_inline(component) }
    let(:rows) { rendered.css(".govuk-summary-list__row") }

    it "renders the title of the qualification" do
      expect(rendered.css("h2").text).to eq(qualification.name)
    end

    it "renders the status" do
      expect(rows[0].text).to include("Qualified Teacher Status (QTS)")
    end

    it "renders the awarded at date" do
      expect(rows[1].text).to include(qualification.awarded_at.to_fs(:long_uk))
    end
  end

  describe "rendering QTS via QTLS when teacher doesnt have QTS and has set membership active" do
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
        qtls_only: true,
        set_membership_active: true,
        passed_induction: false,
        qts_and_qtls: false,
        name: "Qualified teacher status (QTS)",
        type: :qts,
      )
    end
    let(:component) { described_class.new(qualification:) }
    let(:rendered) { render_inline(component) }
    let(:rows) { rendered.css(".govuk-summary-list__row") }

    it "renders two rows" do
      expect(rows.count).to eq(2)
    end

    it "renders the title of the qualification" do
      expect(rendered.css("h2").text).to eq(qualification.name)
    end

    it "renders the status description" do
      expect(rows[0].text).to include("Qualified via qualified teacher learning and skills (QTLS) status")
    end

    it "renders the awarded at date" do
      expect(rows[1].text).to include(qualification.awarded_at.to_fs(:long_uk))
    end
  end

  describe "rendering QTS via QTLS when teacher doesnt have QTS and has set membership expired" do
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
        qtls_only: true,
        set_membership_active: false,
        passed_induction: false,
        qts_and_qtls: false,
        name: "Qualified teacher status (QTS)",
        type: :qts,
      )
    end
    let(:component) { described_class.new(qualification:) }
    let(:rendered) { render_inline(component) }
    let(:rows) { rendered.css(".govuk-summary-list__row") }

    it "renders the title of the qualification" do
      expect(rendered.css("h2").text).to eq(qualification.name)
    end

    it "renders the status description" do
      expect(rows[0].text).to include("No QTS")
    end

    it "renders only one row" do
      expect(rows.count).to eq(1)
    end
  end

  describe "rendering QTS via QTLS when teacher has QTS and has set membership active" do
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
        qtls_only: false,
        set_membership_active: true,
        passed_induction: false,
        qts_and_qtls: true,
        name: "Qualified teacher status (QTS)",
        type: :qts,
      )
    end
    let(:component) { described_class.new(qualification:) }
    let(:rendered) { render_inline(component) }
    let(:rows) { rendered.css(".govuk-summary-list__row") }

    it "renders two rows" do
      expect(rows.count).to eq(2)
    end

    it "renders the title of the qualification" do
      expect(rendered.css("h2").text).to eq(qualification.name)
    end

    it "renders the status description" do
      expect(rows[0].text).to include("Qualified")
      expect(rows[0].text).not_to include("via qualified teacher learning and skills (QTLS) status")
    end

    it "renders the awarded date" do
      expect(rows[1].text).to include(qualification.awarded_at.to_fs(:long_uk))
    end
  end

  describe "rendering QTS when teacher has QTS and QTLS, no induction, set membership active" do
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
        qtls_only: false,
        set_membership_active: true,
        passed_induction: false,
        qts_and_qtls: true,
        name: "Qualified teacher status (QTS)",
        type: :qts,
      )
    end
    let(:component) { described_class.new(qualification:) }
    let(:rendered) { render_inline(component) }
    let(:rows) { rendered.css(".govuk-summary-list__row") }

    it "renders one row" do
      expect(rows.count).to eq(2)
    end

    it "renders the title of the qualification" do
      expect(rendered.css("h2").text).to eq(qualification.name)
    end

    it "renders the status" do
      expect(rows[0].text).to include("Qualified Teacher Status (QTS)")
    end

    it "renders the awarded at date" do
      expect(rows[1].text).to include(qualification.awarded_at.to_fs(:long_uk))
    end
  end

  describe "rendering Induction, teacher has QTS and QTLS, hasnt completed induction, has set membership active" do
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
        qtls_only: true,
        set_membership_active: true,
        passed_induction: false,
        qts_and_qtls: true,
        name: "Induction",
        details: CoercedDetails.new({ status: "Not complete" }),
        type: :induction,
      )
    end

    let(:component) { described_class.new(qualification:) }
    let(:rendered) { render_inline(component) }
    let(:rows) { rendered.css(".govuk-summary-list__row") }

    it "renders two rows" do
      expect(rows.count).to eq(1)
    end

    it "renders the qualification name" do
      expect(rendered.css("h2").text).to eq(qualification.name)
    end

    it "renders the status description" do
      expect(rows[0].text).to include("Exempt")
    end
  end

  describe "rendering Induction not passed when teacher has QTLS but not QTS and has set membership active" do
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
        qtls_only: true,
        set_membership_active: true,
        passed_induction: false,
        qts_and_qtls: false,
        name: "Induction",
        details: CoercedDetails.new(status: "Something else"),
        type: :induction,
      )
    end
    
    let(:component) { described_class.new(qualification:) }
    let(:rendered) { render_inline(component) }
    let(:rows) { rendered.css(".govuk-summary-list__row") }

    it "renders two rows" do
      expect(rows.count).to eq(1)
    end

    it "renders the qualification name" do
      expect(rendered.css("h2").text).to eq(qualification.name)
    end

    it "renders the status description" do
      expect(rows[0].text).to include("Exempt")
    end
  end

  describe "rendering Induction when teacher has QTLS but not QTS and has set membership expired" do
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
        qtls_only: true,
        set_membership_active: false,
        passed_induction: false,
        qts_and_qtls: false,
        name: "Induction",
        details: CoercedDetails.new({status: "Something else"}),
        type: :induction,
      )
    end
    
    let(:component) { described_class.new(qualification:) }
    let(:rendered) { render_inline(component) }
    let(:rows) { rendered.css(".govuk-summary-list__row") }

    it "renders two rows" do
      expect(rows.count).to eq(1)
    end

    it "renders the qualification name" do
      expect(rendered.css("h2").text).to eq(qualification.name)
    end

    it "renders the status description" do
      expect(rows[0].text).to include("No induction")
    end
  end
end
