require "rails_helper"

RSpec.describe "The downtime banner", host: :check_records, type: :system do
  include ActivateFeaturesSteps
  include AuthenticationSteps

  scenario "User sees the planned downtime warning after signing in", test: :with_stubbed_auth do
    given_the_check_service_is_open
    and_the_downtime_banner_is_active

    when_i_sign_in_via_dsi
    then_i_see_the_planned_downtime_warning
  end

  private

  def then_i_see_the_planned_downtime_warning
    expect(page).to have_content("Important")
    expect(page).to have_content(
      "This service will be unavailable from 9am to 12pm on Monday 21 September 2026 " \
        "while we make improvements."
    )
  end
end
