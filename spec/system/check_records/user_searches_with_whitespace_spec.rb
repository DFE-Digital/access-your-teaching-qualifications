# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Teacher search", host: :check_records, type: :system do
  include ActivateFeaturesSteps
  include AuthenticationSteps

  after { travel_back }

  scenario "User searches with a last name that has whitespace and finds a record",
           test: %i[with_stubbed_auth with_fake_quals_api] do
    given_the_check_service_is_open
    and_time_is_frozen

    when_i_sign_in_via_dsi
    and_search_with_a_valid_name_and_dob
    then_i_see_a_teacher_record_in_the_results
    then_i_see_previous_last_names
    and_my_search_is_logged
    and_a_search_timestamp_is_displayed

    when_i_click_on_the_teacher_record
    then_the_trn_is_not_in_the_url
    then_i_see_induction_details
    then_i_see_qts_details
    then_i_see_rtps_details
    then_i_see_eyts_details
    then_i_see_other_rtps_details
    then_i_see_npq_details
    then_i_see_mq_details
    and_a_viewed_timestamp_is_displayed
    then_i_see_previous_last_names
    and_a_print_warning_is_displayed
  end

  private

  def and_time_is_frozen
    @frozen_time = Time.zone.local(2020, 1, 1, 10, 21)
    travel_to @frozen_time
  end

  def and_search_with_a_valid_name_and_dob
    fill_in "Last name", with: ["Walsh ", " Walsh", "Walsh\n"].sample
    fill_in "Day", with: ["5 ", " 5", "5"].sample
    fill_in "Month", with: ["April ", " April", "April\n"].sample
    fill_in "Year", with: ["1992 ", " 1992", "1992\n"].sample
    click_button "Find record"
  end

  def then_i_see_a_teacher_record_in_the_results
    expect(page).to have_content "Terry John Walsh"
  end

  def then_the_trn_is_not_in_the_url
    expect(page).to have_current_path("/check-records/teachers/#{SecureIdentifier.encode('1234567')}")
  end

  def and_my_search_is_logged
    search_log = SearchLog.last
    expect(search_log.last_name).to eq "Walsh"
    expect(search_log.date_of_birth.to_s).to eq "1992-04-05"
    expect(search_log.result_count).to eq 1
  end

  def when_i_click_on_the_teacher_record
    click_on "Terry John Walsh"
  end

  def then_i_see_induction_details
    expect(page).to have_content("Induction")
    expect(page).to have_content("Exempt")
  end

  def then_i_see_qts_details
    expect(page).to have_content("Qualified teacher status (QTS)")
    expect(page).to have_content("Held since\t27 February 2023")
  end

  def then_i_see_eyts_details
    expect(page).to have_content("Early years teacher status (EYTS)")
    expect(page).to have_content("Held since\t27 February 2023")
  end

  def then_i_see_rtps_details
    expect(page).to have_content("Qualification\tBA")
    expect(page).to have_content("Provider\tEarl Spencer Primary School")
    expect(page).to have_content("Subject\tBusiness Studies")
    expect(page).to have_content("Age range\t7 to 14 years")
    expect(page).to have_content("Start date\t28 February 2022")
    expect(page).to have_content("End date\t28 January 2023")
    expect(page).to have_content("Result\tHolds")
  end

  def then_i_see_other_rtps_details
    expect(page).to have_content("Qualification\tBA")
    expect(page).to have_content("Provider\tEarl Spencer Secondary School")
    expect(page).to have_content("Subject\tBusiness Studies")
    expect(page).to have_content("Age range\t15 to 18 years")
    expect(page).to have_content("Start date\t28 February 2022")
    expect(page).to have_content("End date\t28 January 2030")
    expect(page).to have_content("Result\tIn training")
  end

  def then_i_see_npq_details
    expect(page).to have_content("Date NPQ for Early Years Leadership awarded")
    expect(page).to have_content("27 February 2023")
  end

  def then_i_see_mq_details
    expect(page).to have_content("MQ Specialism\tVisual impairment")
    expect(page).to have_content("Date Awarded\t28 February 2023")
    expect(page).to have_content("MQ Specialism\tHearing")
    expect(page).to have_content("Date Awarded\t1 January 2022")
  end


  def and_a_search_timestamp_is_displayed
    expect(page).to have_content "Searched at 10:21am on 1 January 2020"
  end

  def and_a_viewed_timestamp_is_displayed
    expect(page).to have_content "Viewed at 10:21am on 1 January 2020"
  end

  def and_a_print_warning_is_displayed
    expect(page).to have_content "You should dispose of the offline records"
  end
end
def then_i_see_previous_last_names
  expect(page).to have_content("Previous last names")
  expect(page).to have_content("Jones\nSmith")
end
