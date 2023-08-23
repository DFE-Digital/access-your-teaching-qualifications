require "rails_helper"

RSpec.describe "Teacher search with restrictions",
               host: :check_records,
               type: :system do
  include ActivateFeaturesSteps
  include CheckRecords::AuthenticationSteps

  scenario "User searches with a last name and date of birth and finds a restricted record",
           test: %i[with_stubbed_auth with_fake_quals_api] do
    given_the_service_is_open
    when_i_sign_in_via_dsi
    and_search_returns_a_restricted_record
    then_i_see_the_restriction_on_the_result
  end

  private

  def and_search_returns_a_restricted_record
    fill_in "Last name", with: "Restricted"
    fill_in "Day", with: "1"
    fill_in "Month", with: "1"
    fill_in "Year", with: "1990"
    click_button "Find record"
  end

  def then_i_see_the_restriction_on_the_result
    expect(page).to have_content("RESTRICTIONS")
  end
end