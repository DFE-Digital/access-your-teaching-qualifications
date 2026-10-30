require "rails_helper"

RSpec.feature "The AYTQ unavailable banner", type: :system do
  include CommonSteps

  scenario "User sees the technical issue warning on the start page" do
    given_the_qualifications_service_is_open
    FeatureFlags::FeatureFlag.activate(:aytq_unavailable_banner)

    visit qualifications_start_path

    expect(page).to have_content("Important")
    expect(page).to have_content(
      "Due to a technical issue, AYTQ is currently unavailable. Please try again later."
    )
  end
end
