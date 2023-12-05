require "rails_helper"

RSpec.feature "The qualifications start page", type: :system do
  include CommonSteps

  scenario "when a user views the start page", test: :with_stubbed_auth do
    given_the_qualifications_service_is_open

    when_i_visit_the_qualifications_start_page
    then_i_see_the_start_page
  end

  private

  def when_i_visit_the_qualifications_start_page
    visit qualifications_start_path
  end

  def then_i_see_the_start_page
    expect(page).to have_content("Access your teaching qualifications")
    expect(page).to have_button("Start now")
  end
end
