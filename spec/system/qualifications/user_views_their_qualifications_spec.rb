require "rails_helper"

RSpec.feature "User views their qualifications", type: :system do
  include CommonSteps
  include QualificationAuthenticationSteps

  scenario "when they have qualifications", test: %i[with_stubbed_auth with_fake_quals_api] do
    given_the_service_is_open
    and_i_am_signed_in_via_identity

    when_i_visit_the_qualifications_page
    then_i_see_my_induction_details
    then_i_see_my_qts_details
    and_my_qts_certificate_is_downloadable
    then_i_see_my_itt_details
    then_i_see_my_eyts_details
    and_my_eyts_certificate_is_downloadable
    then_i_see_my_npq_details
    and_my_npq_certificate_is_downloadable
    then_i_see_my_mq_details
    and_event_tracking_is_working
  end

  private

  def when_i_visit_the_qualifications_page
    visit qualifications_dashboard_path
  end

  def then_i_see_my_induction_details
    expect(page).to have_content("Induction")
    expect(page).to have_content("Pass")
    expect(page).to have_content("1 October 2022")
    expect(page).to have_link("Download Induction certificate")
    find("span", text: "Induction history").click
    expect(page).to have_content("Induction body")
    expect(page).to have_content("1 September 2022")
    expect(page).to have_content("Number of terms\t1")
  end

  def then_i_see_my_qts_details
    expect(page).to have_content("Qualified teacher status (QTS)")
    expect(page).to have_content("Awarded")
    expect(page).to have_content("27 February 2023")
    expect(page).to have_content("Download QTS certificate")
  end

  def then_i_see_my_eyts_details
    expect(page).to have_content("Early years teacher status (EYTS)")
    expect(page).to have_content("Awarded")
    expect(page).to have_content("27 February 2023")
    expect(page).to have_content("Download EYTS certificate")
  end

  def and_my_qts_certificate_is_downloadable
    click_on "Download QTS certificate"
    expect(page.response_headers["Content-Type"]).to eq("application/pdf")
    expect(page.response_headers["Content-Disposition"]).to include("attachment")
    expect(page.response_headers["Content-Disposition"]).to include(
      "filename=\"Test User_qts_certificate.pdf\";"
    )
  end

  def and_my_eyts_certificate_is_downloadable
    click_on "Download EYTS certificate"
    expect(page.response_headers["Content-Type"]).to eq("application/pdf")
    expect(page.response_headers["Content-Disposition"]).to include("attachment")
    expect(page.response_headers["Content-Disposition"]).to include(
      "filename=\"Test User_eyts_certificate.pdf\";"
    )
  end

  def then_i_see_my_itt_details
    expect(page).to have_content("Initial teacher training (ITT)")
    expect(page).to have_content("BA")
    expect(page).to have_content("Earl Spencer Primary School")
    expect(page).to have_content("Higher education institution")
    expect(page).to have_content("Business Studies")
    expect(page).to have_content("28 February 2022")
    expect(page).to have_content("28 January 2023")
    expect(page).to have_content("Status\tPass")
    expect(page).to have_content("10 to 16 years")
  end

  def then_i_see_my_npq_details
    expect(page).to have_content("NPQ headteacher")
    expect(page).to have_content("Awarded")
    expect(page).to have_content("27 February 2023")
    expect(page).to have_content("Download NPQH certificate")
  end

  def and_my_npq_certificate_is_downloadable
    click_on "Download NPQH certificate"
    expect(page.response_headers["Content-Type"]).to eq("application/pdf")
    expect(page.response_headers["Content-Disposition"]).to include("attachment")
    expect(page.response_headers["Content-Disposition"]).to include(
      "filename=\"Test User_npq_certificate.pdf\";"
    )
  end

  def then_i_see_my_mq_details
    expect(page).to have_content("Mandatory qualification (MQ)")
    expect(page).to have_content("Awarded\t28 February 2023")
    expect(page).to have_content("Specialism\tVisual impairment")
  end
end
