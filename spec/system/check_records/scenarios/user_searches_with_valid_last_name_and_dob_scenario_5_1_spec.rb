# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Check Teacher Records", host: :check_records, type: :system do
  include ActivateFeaturesSteps
  include AuthenticationSteps

  before do
    allow_any_instance_of(FakeQualificationsData).to receive(:quals_data).and_return(override_quals_data)
  end

  let(:override_quals_data) do
    {
      "trn": "3012593",
      "firstName": "Christopher",
      "middleName": "Scenario ",
      "lastName": "Five One",
      "dateOfBirth": "1985-09-04",
      "nationalInsuranceNumber": nil,
      "pendingNameChange": false,
      "pendingDateOfBirthChange": false,
      "emailAddress": nil,
      "qts": {
        "holdsFrom": "2025-01-01",
        "routes": [
          {
            "routeToProfessionalStatusType": {
              "routeToProfessionalStatusTypeId": "6f27bdeb-d00a-4ef9-b0ea-26498ce64713",
              "name": "Apply for Qualified Teacher Status in England",
              "professionalStatusType": "QualifiedTeacherStatus"
            }
          }
        ]
      },
      "eyts": nil,
      "induction": {
        "status": "RequiredToComplete",
        "startDate": nil,
        "completedDate": nil,
        "exemptionReasons": []
      },
      "routesToProfessionalStatuses": [
        {
          "routeToProfessionalStatusId": "778f50a4-e19b-42c7-ab93-abd048fa2507",
          "routeToProfessionalStatusType": {
            "routeToProfessionalStatusTypeId": "6f27bdeb-d00a-4ef9-b0ea-26498ce64713",
            "name": "Apply for Qualified Teacher Status in England",
            "professionalStatusType": "QualifiedTeacherStatus"
          },
          "status": "Holds",
          "holdsFrom": "2025-01-01",
          "trainingStartDate": nil,
          "trainingEndDate": nil,
          "trainingSubjects": [],
          "trainingAgeSpecialism": nil,
          "trainingCountry": {
            "reference": "GB-ENG",
            "name": "England"
          },
          "trainingProvider": nil,
          "degreeType": nil,
          "inductionExemption": {
            "isExempt": false,
            "exemptionReasons": []
          }
        }
      ],
      "mandatoryQualifications": [],
      "alerts": [],
      "previousNames": [],
      "qtlsStatus": "Expired"
    }
  end

  after { travel_back }

  scenario "Scenario 5.1",
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
    then_i_see_induction_details
    then_i_see_qts_details
    then_i_see_qts_rtps_details
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

  def then_i_see_induction_details
    expect(page).to have_content("Induction")
    expect(page).to have_content("Required to complete")
  end

  def then_i_see_qts_details
    expect(page).to have_content("Qualified teacher status (QTS)")
    expect(page).to have_content("Held since\t1 January 2025")
  end

  def then_i_see_qts_rtps_details
    expect(page).to have_content("Route to QTS: Apply for Qualified Teacher Status in England")
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
