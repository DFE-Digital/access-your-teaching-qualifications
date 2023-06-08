# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Teacher search", host: :check_records, type: :system do
  include ActivateFeaturesSteps
  include CheckRecords::AuthenticationSteps

  scenario "User searches with invalid values and sees errors",
           test: %i[with_stubbed_auth with_fake_quals_api] do
    given_the_service_is_open
    when_i_sign_in_via_dsi
    and_press_find_record
    then_i_see_the_missing_name_error
    then_i_see_the_missing_dob_error

    when_i_enter_a_valid_name
    and_press_find_record
    then_i_see_the_missing_dob_error

    when_i_enter_a_date_of_birth
    and_press_find_record
    then_the_search_is_successful
  end

  private

  def when_i_enter_a_valid_name
    fill_in "Last name", with: "Walsh"
  end

  def when_i_enter_a_date_of_birth
    fill_in "Day", with: "1"
    fill_in "Month", with: "January"
    fill_in "Year", with: "1990"
  end

  def and_press_find_record
    click_button "Find record"
  end

  def then_i_see_the_missing_dob_error
    expect(page).to have_content "Date of birth\nError:\nEnter a valid date of birth"
  end

  def then_i_see_the_missing_name_error
    expect(page).to have_content "Last name\nError:\nEnter a last name"
  end

  def then_the_search_is_successful
    expect(page).to have_content "Terry Walsh"
  end
end
