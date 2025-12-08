# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Check Teacher Records", host: :check_records, type: :system do
  include ActivateFeaturesSteps
  include AuthenticationSteps

  before do
    allow_any_instance_of(FakeQualificationsData).to receive(:quals_data).and_return(override_quals_data)
  end

  let(:override_quals_data) {
    {
      "trn": "3012586",
      "firstName": "Christopher",
      "middleName": "Scenario",
      "lastName": "Two",
      "dateOfBirth": "1985-09-04",
      "nationalInsuranceNumber": nil,
      "pendingNameChange": false,
      "pendingDateOfBirthChange": false,
      "emailAddress": nil,
      "qts": nil,
      "eyts": nil,
      "induction": {
        "status": "None",
        "startDate": nil,
        "completedDate": nil,
        "exemptionReasons": []
      },
      "routesToProfessionalStatuses": [],
      "mandatoryQualifications": [],
      "alerts": [],
      "previousNames": [],
      "qtlsStatus": "Expired"
    }
  }

  after { travel_back }

  scenario "Scenario 2",
           test: %i[with_stubbed_auth with_fake_quals_api] do
    given_the_check_service_is_open
    and_time_is_frozen

    when_i_sign_in_via_dsi
    and_search_with_a_valid_name_and_dob
    then_i_see_a_teacher_record_in_the_results
    and_my_search_is_logged
    and_a_search_timestamp_is_displayed

    when_i_click_on_the_teacher_record
    then_the_trn_is_not_in_the_url
    save_screenshot("scenario_screenshots/ctr/scenario_2.png", full: true)
    then_i_see_an_expired_qtls_message
    then_i_see_npq_details
    and_a_viewed_timestamp_is_displayed
    and_a_print_warning_is_displayed
  end

  private

  def and_time_is_frozen
    @frozen_time = Time.zone.local(2020, 1, 1, 10, 21)
    travel_to @frozen_time
  end

  def and_search_with_a_valid_name_and_dob
    fill_in "Last name", with: "Walsh"
    fill_in "Day", with: "5"
    fill_in "Month", with: "April"
    fill_in "Year", with: "1992"
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

  def then_i_see_an_expired_qtls_message
    expect(page).to have_content("No longer has QTS via QTLS status because their Society for Education and Training (SET) membership expired")
  end

  def then_i_see_npq_details
    expect(page).to have_content("Date NPQ for Headship awarded")
    expect(page).to have_content("27 February 2023")
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
