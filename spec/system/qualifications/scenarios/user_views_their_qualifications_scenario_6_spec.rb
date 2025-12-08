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
      "trn": "3012589",
      "firstName": "Christopher",
      "middleName": "Scenario",
      "lastName": "Six",
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
          },
          {
            "routeToProfessionalStatusType": {
              "routeToProfessionalStatusTypeId": "be6eaf8c-92dd-4eff-aad3-1c89c4bec18c",
              "name": "QTLS and SET Membership",
              "professionalStatusType": "QualifiedTeacherStatus"
            }
          }
        ]
      },
      "eyts": nil,
      "induction": {
        "status": "Failed",
        "startDate": "2025-01-01",
        "completedDate": "2025-03-01",
        "exemptionReasons": [
          {
            "inductionExemptionReasonId": "35caa6a3-49f2-4a63-bd5a-2ba5fa9dc5db",
            "name": "Exempt through QTLS status provided they maintain membership of The Society of Education and Training"
          }
        ]
      },
      "routesToProfessionalStatuses": [
        {
          "routeToProfessionalStatusId": "33c2ccb5-d4a2-4920-bc81-ef38e31396d1",
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
        },
        {
          "routeToProfessionalStatusId": "8d9aea28-88ff-4477-bc14-4b26520d5509",
          "routeToProfessionalStatusType": {
            "routeToProfessionalStatusTypeId": "be6eaf8c-92dd-4eff-aad3-1c89c4bec18c",
            "name": "QTLS and SET Membership",
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
            "isExempt": true,
            "exemptionReasons": [
              {
                "inductionExemptionReasonId": "35caa6a3-49f2-4a63-bd5a-2ba5fa9dc5db",
                "name": "Exempt through QTLS status provided they maintain membership of The Society of Education and Training"
              }
            ]
          }
        }
      ],
      "mandatoryQualifications": [],
      "alerts": [],
      "previousNames": [],
      "qtlsStatus": "Active"
    }
  }

  scenario "scenario 6",
           test: %i[with_stubbed_auth with_fake_quals_api] do
    given_the_qualifications_service_is_open
    and_i_am_signed_in_via_identity

    when_i_visit_the_qualifications_page
    save_screenshot("scenario_screenshots/aytq/scenario_6.png", full: true)
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
    expect(page).to have_content("Failed")
    expect(page).to have_content("1 March 2025")
  end

  def then_i_see_my_qts_details
    expect(page).to have_content("Qualified teacher status (QTS)")
    expect(page).to have_content("Held since")
    expect(page).to have_content("27 February 2023")
    expect(page).to have_content("Download QTS certificate")
  end

  def and_my_qts_certificate_is_downloadable
    click_on "Download QTS certificate"
    expect(page.response_headers["content-type"]).to eq("application/pdf")
    expect(page.response_headers["content-disposition"]).to include("attachment")
    expect(page.response_headers["content-disposition"]).to include("filename=\"#{full_name}_qts_certificate.pdf\";")
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
    expect(page.response_headers["content-disposition"]).to include("filename=\"#{full_name}_npqh_certificate.pdf\";")
  end
end
