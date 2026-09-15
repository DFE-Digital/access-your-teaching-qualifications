require "rails_helper"

RSpec.feature "The downtime banner", type: :system do
  include CommonSteps

  scenario "User sees the planned downtime warning on the start page" do
    given_the_qualifications_service_is_open
    and_the_downtime_banner_is_active

    when_i_visit_the_qualifications_start_page
    then_i_see_the_planned_downtime_warning
  end

  private

  def when_i_visit_the_qualifications_start_page
    visit qualifications_start_path
  end

  def then_i_see_the_planned_downtime_warning
    expect(page).to have_content("Important")
    expect(page).to have_content(
      "This service will be unavailable from 9am to 12pm on Monday 21 September 2026 " \
        "while we make improvements."
    )
  end
end
