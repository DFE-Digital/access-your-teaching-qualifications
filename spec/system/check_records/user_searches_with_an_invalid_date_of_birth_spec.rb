# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Teacher search", host: :check_records, type: :system do
  include ActivateFeaturesSteps
  include CheckRecords::AuthenticationSteps

  scenario "User searches with an invalid date of birth",
           test: %i[with_stubbed_auth with_fake_quals_api] do
    given_the_service_is_open
    when_i_sign_in_via_dsi
    and_search_with_a_missing_dob
    then_i_see_an_error_message
  end

  private

  def and_search_with_a_missing_dob
    fill_in "Last name", with: "Walsh"
    fill_in "Day", with: "5"
    fill_in "Month", with: "April"
    click_button "Find record"
  end

  def then_i_see_an_error_message
    expect(page).to have_text("Enter a year with 4 digits")
    page.click_link("Enter a year with 4 digits")
    expect(page).to have_css("#search-year-field-error")
  end
end