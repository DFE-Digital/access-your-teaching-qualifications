require 'rails_helper'

RSpec.describe "Teacher search", host: :check_records, type: :system do
  include ActivateFeaturesSteps
  include AuthenticationSteps

  scenario "User searches for someone that has a record but no details",
           test: %i[with_stubbed_auth with_fake_quals_api] do
    given_the_check_service_is_open
    when_i_sign_in_via_dsi
    and_search_with_a_valid_name_and_dob
    then_i_see_a_teacher_record_in_the_results

    when_i_click_on_the_teacher_record
    then_i_see_this_teacher_has_no_details
  end
  
  private

  def and_search_with_a_valid_name_and_dob
    fill_in "Last name", with: "No_data"
    fill_in "Day", with: "5"
    fill_in "Month", with: "April"
    fill_in "Year", with: "1992"
    click_button "Find record"
  end

  def then_i_see_a_teacher_record_in_the_results
    expect(page).to have_content "Terry John Walsh"
  end

  def when_i_click_on_the_teacher_record
    click_on "Terry John Walsh"
  end

  def then_i_see_this_teacher_has_no_details
    expect(page).to have_content(
      "We have no details of this person's qualifications, teacher status or induction status."
    )
  end
end