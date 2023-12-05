require "rails_helper"

RSpec.describe "No matches", host: :check_records, type: :system do
  include ActivateFeaturesSteps
  include CheckRecords::AuthenticationSteps

  scenario "User searches with a last name and date of birth and finds no matches",
           test: %i[with_stubbed_auth with_fake_quals_api] do
    given_the_check_service_is_open
    when_i_sign_in_via_dsi
    and_search_returns_no_records
    then_i_see_no_records
  end

  private

  def and_search_returns_no_records
    fill_in "Last name", with: "No match"
    fill_in "Day", with: "1"
    fill_in "Month", with: "1"
    fill_in "Year", with: "1990"
    click_button "Find record"
  end

  def then_i_see_no_records
    expect(page).to have_content("No teachers found")
    expect(page).to have_link("Try another search")
  end
end
