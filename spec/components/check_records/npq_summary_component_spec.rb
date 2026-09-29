require "rails_helper"

RSpec.describe CheckRecords::NpqSummaryComponent, type: :component do
  let(:rendered) { render_inline(described_class.new(npqs:)) }

  context "with an award date" do
    let(:npqs) do
      [Qualification.new(awarded_at: Date.new(2023, 2, 27),
                         name: "National Professional Qualification (NPQ) for Headship", type: :NPQH)]
    end

    it "renders the date" do
      expect(rendered.text).to include("Date NPQ for Headship awarded").and include("27 February 2023")
    end
  end

  context "without an award date" do
    let(:npqs) do
      [Qualification.new(awarded_at: nil, name: "National Professional Qualification (NPQ) for Headship", type: :NPQH)]
    end

    it "renders the row with the date as not known" do
      expect(rendered.text).to include("Date NPQ for Headship awarded").and include("Not known")
    end
  end
end
