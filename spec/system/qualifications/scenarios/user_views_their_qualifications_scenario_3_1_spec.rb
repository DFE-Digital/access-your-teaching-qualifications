require "rails_helper"

RSpec.feature "User views their qualifications", type: :system do
  include CommonSteps
  include QualificationAuthenticationSteps

  before do
    allow_any_instance_of(FakeQualificationsData).to receive(:quals_data).and_return(override_quals_data)
  end

  let(:full_name) { override_quals_data.slice(:firstName, :middleName, :lastName).values.map(&:strip).join(" ") }
  let(:override_quals_data) {
    {
      "trn": "3012602",
      "firstName": "Christopher",
      "middleName": "Scenario",
      "lastName": "Three One",
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
          "routeToProfessionalStatusId": "cb158f27-d7fb-4ed9-81f4-16014f4a92ef",
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
      "qtlsStatus": "None"
    }
  }

  scenario "scenario 3.1",
           test: %i[with_stubbed_auth with_fake_quals_api] do
    given_the_qualifications_service_is_open
    and_i_am_signed_in_via_identity

    when_i_visit_the_qualifications_page
    save_screenshot("scenario_screenshots/aytq/scenario_3_1.png", full: true)
    then_i_see_my_induction_details
    then_i_see_my_qts_details
    and_my_qts_certificate_is_downloadable
    then_i_see_my_npq_details
    and_my_npq_certificate_is_downloadable
    and_event_tracking_is_working
  end

  private

  def when_i_visit_the_qualifications_page
    visit qualifications_dashboard_path
  end

  def then_i_see_my_induction_details
    expect(page).to have_content("Induction")
    expect(page).to have_content("Required to complete")
  end

  def then_i_see_my_qts_details
    expect(page).to have_content("Qualified teacher status (QTS)")
    expect(page).to have_content("Held since")
    expect(page).to have_content("27 February 2023")
    expect(page).to have_content("Download QTS certificate")
  end

  def then_i_see_my_eyts_details
    expect(page).to have_content("Early years teacher status (EYTS)")
    expect(page).to have_content("Held since")
    expect(page).to have_content("27 February 2023")
    expect(page).to have_content("Download EYTS certificate")
  end

  def and_my_qts_certificate_is_downloadable
    click_on "Download QTS certificate"
    expect(page.response_headers["content-type"]).to eq("application/pdf")
    expect(page.response_headers["content-disposition"]).to include("attachment")
    expect(page.response_headers["content-disposition"]).to include(
                                                              "filename=\"#{full_name}_qts_certificate.pdf\";"
                                                            )
  end

  def and_my_eyts_certificate_is_downloadable
    click_on "Download EYTS certificate"
    expect(page.response_headers["content-type"]).to eq("application/pdf")
    expect(page.response_headers["content-disposition"]).to include("attachment")
    expect(page.response_headers["content-disposition"]).to include(
                                                              "filename=\"#{full_name}_eyts_certificate.pdf\";"
                                                            )
  end

  def then_i_see_my_rtps_details
    expect(page).to have_content("Initial teacher training (ITT)")
    expect(page).to have_content("BA")
    expect(page).to have_content("Earl Spencer Primary School")
    expect(page).to have_content("Business Studies")
    expect(page).to have_content("28 February 2022")
    expect(page).to have_content("28 January 2023")
    expect(page).to have_content("Status\tPass")
    expect(page).to have_content("7 to 14 years")
  end

  def then_i_see_my_npq_details
    expect(page).to have_content("National Professional Qualification (NPQ) for Headship")
    expect(page).to have_content("Held since")
    expect(page).to have_content("27 February 2023")
    expect(page).to have_content("Download NPQH certificate")
  end

  def and_my_npq_certificate_is_downloadable
    click_on "Download NPQH certificate"
    expect(page.response_headers["content-type"]).to eq("application/pdf")
    expect(page.response_headers["content-disposition"]).to include("attachment")
    expect(page.response_headers["content-disposition"]).to include(
                                                              "filename=\"#{full_name}_npqh_certificate.pdf\";"
                                                            )
  end

  def then_i_see_my_mq_details
    expect(page).to have_content("Mandatory qualification (MQ)")
    expect(page).to have_content("Held since\t28 February 2023")
    expect(page).to have_content("Specialism\tVisual impairment")
  end
end
