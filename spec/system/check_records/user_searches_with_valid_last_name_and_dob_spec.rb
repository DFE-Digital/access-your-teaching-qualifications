# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Teacher search", host: :check_records, type: :system do
  include ActivateFeaturesSteps
  include CheckRecords::AuthenticationSteps

  scenario "User searches with a last name and date of birth and finds a record",
           test: %i[with_stubbed_auth with_fake_quals_api] do
    given_the_service_is_open
    when_i_sign_in_via_dsi
    and_search_with_a_valid_name_and_dob
    then_i_see_a_teacher_record_in_the_results
    and_my_search_is_logged

    when_i_click_on_the_teacher_record
    then_i_see_induction_details
    then_i_see_qts_details
    then_i_see_itt_details
    then_i_see_eyts_details
    then_i_see_npq_details
    then_i_see_mq_details
  end

  private

  def and_search_with_a_valid_name_and_dob
    fill_in "Last name", with: "Walsh"
    fill_in "Day", with: "5"
    fill_in "Month", with: "April"
    fill_in "Year", with: "1992"
    click_button "Find record"
  end

  def then_i_see_a_teacher_record_in_the_results
    expect(page).to have_content "Terry Walsh"
  end

  def and_my_search_is_logged
    expect(SearchLog.last.last_name).to eq "Walsh"
    expect(SearchLog.last.date_of_birth.to_s).to eq "1992-04-05"
  end

  def when_i_click_on_the_teacher_record
    click_on "Terry Walsh"
  end

  def then_i_see_induction_details
    expect(page).to have_content("Induction")
    expect(page).to have_content("Pass")
    expect(page).to have_content("1 October 2022")
  end

  def then_i_see_qts_details
    expect(page).to have_content("Qualified teacher status (QTS)")
    expect(page).to have_content("Date awarded")
    expect(page).to have_content("27 February 2023")
  end

  def then_i_see_eyts_details
    expect(page).to have_content("Early years teacher status (EYTS)")
    expect(page).to have_content("Date awarded")
    expect(page).to have_content("27 February 2023")
  end

  def then_i_see_itt_details
    expect(page).to have_content("Initial teacher training (ITT)")
    expect(page).to have_content("BA")
    expect(page).to have_content("Earl Spencer Primary School")
    expect(page).to have_content("Higher education institution")
    expect(page).to have_content("Business Studies")
    expect(page).to have_content("28 January 2023")
    expect(page).to have_content("Pass")
  end

  def then_i_see_npq_details
    expect(page).to have_content("Date NPQ headteacher awarded")
    expect(page).to have_content("27 February 2023")
  end

  def then_i_see_mq_details
    expect(page).to have_content("Mandatory qualification (MQ)")
    expect(page).to have_content("Date awarded\t28 February 2023")
    expect(page).to have_content("Specialism\tVisual impairment")
  end
end
