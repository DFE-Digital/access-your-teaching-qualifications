# frozen_string_literal: true

require "rails_helper"

RSpec.describe ActionAtComponent, type: :component do
  subject(:rendered_component) { render_inline(described_class.new(action:)).css(".govuk-caption-m").to_html }

  let(:action) { "Viewed" }
  let(:frozen_time) { Time.zone.local(2020, 6, 1, 10, 21) }

  it "renders the timestamp" do
    travel_to(frozen_time) do
      expect(rendered_component).to include("Viewed at 10:21am on 1 June 2020")
    end
  end

  context "when the action is 'Created'" do
    let(:action) { "Created" }

    it "renders the action correctly" do
      travel_to(frozen_time) do
        expect(rendered_component).to include("Created at")
      end
    end
  end

  context "when the current timezone is not UTC" do
    let(:frozen_time) { Time.parse("2020-06-01 10:21:00 UTC") }

    before do
      Time.zone = "Eastern Time (US & Canada)"
    end

    after do
      Time.zone = "UTC"
    end

    it "renders the timestamp in the London timezone" do
      travel_to(frozen_time) do
        expect(rendered_component).to include("Viewed at 11:21am on 1 June 2020")
      end
    end
  end
end
