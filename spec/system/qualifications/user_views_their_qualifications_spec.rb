require "rails_helper"

RSpec.feature "User views their qualifications", type: :system do
  include CommonSteps
  include QualificationAuthenticationSteps

  scenario "when they have qualifications",
           test: %i[with_stubbed_auth with_fake_quals_api] do
    given_the_qualifications_service_is_open
    and_i_am_signed_in_via_onelogin

    when_i_visit_the_qualifications_page
    then_i_see_my_induction_details
    then_i_see_my_qts_details
    and_my_qts_certificate_is_downloadable
    then_i_see_my_rtps_details
    then_i_see_my_eyts_details
    and_my_eyts_certificate_is_downloadable
    then_i_see_my_npq_details
    and_my_npq_certificate_is_downloadable
    then_i_see_my_mq_details
    and_event_tracking_is_working
  end

  scenario "when the NPQ API is unavailable",
           test: %i[with_stubbed_auth with_fake_quals_api] do
    given_the_qualifications_service_is_open
    and_the_npq_api_is_unavailable
    and_i_am_signed_in_via_onelogin

    when_i_visit_the_qualifications_page
    then_i_see_the_npq_error_banner
    then_i_see_my_induction_details
    and_i_do_not_see_my_npq_details
  end

  {
    "an HTML maintenance page" => { headers: { "Content-Type" => "text/html" }, body: "<html>Maintenance</html>" },
    "an empty JSON body" => { headers: { "Content-Type" => "application/json" }, body: "" },
  }.each do |description, response|
    scenario "when the NPQ API returns #{description}",
             test: %i[with_stubbed_auth with_fake_quals_api] do
      given_the_qualifications_service_is_open
      and_the_npq_api_returns(response)
      and_i_am_signed_in_via_onelogin

      when_i_visit_the_qualifications_page
      then_i_see_the_npq_error_banner
      then_i_see_my_induction_details
      and_i_do_not_see_my_npq_details
    end
  end

  private

  def and_the_npq_api_is_unavailable
    stub_request(:get, %r{/api/teacher-record-service/v1/qualifications/}).to_return(status: 500)
  end

  def and_the_npq_api_returns(response)
    stub_request(:get, %r{/api/teacher-record-service/v1/qualifications/}).to_return(status: 200, **response)
  end

  def then_i_see_the_npq_error_banner
    expect(page).to have_content(
      "There was an error and we cannot display your NPQ qualifications. Try again later."
    )
  end

  def and_i_do_not_see_my_npq_details
    expect(page).not_to have_content("National Professional Qualification (NPQ) for Headship")
  end

  def when_i_visit_the_qualifications_page
    visit qualifications_dashboard_path
  end

  def then_i_see_my_induction_details
    expect(page).to have_content("Induction")
    expect(page).to have_content("Exempt")
  end

  def then_i_see_my_qts_details
    expect(page).to have_content("QTS via qualified teacher learning and skills (QTLS)")
    expect(page).to have_content("Held since")
    expect(page).to have_content("27 February 2023")
    expect(page).to have_content("Download QTLS certificate")
  end

  def then_i_see_my_eyts_details
    expect(page).to have_content("Early years teacher status (EYTS)")
    expect(page).to have_content("Held since")
    expect(page).to have_content("27 February 2023")
    expect(page).to have_content("Download EYTS certificate")
  end

  def and_my_qts_certificate_is_downloadable
    download_certificate("Download QTLS certificate", filename: "Terry Walsh_qtls_certificate.pdf")
    expect(page.response_headers["content-type"]).to eq("application/pdf")
    expect(page.response_headers["content-disposition"]).to include(
                                                              "attachment"
                                                            )
    expect(page.response_headers["content-disposition"]).to include(
                                                              "filename=\"Terry Walsh_qtls_certificate.pdf\";"
                                                            )
  end

  def and_my_eyts_certificate_is_downloadable
    download_certificate("Download EYTS certificate", filename: "Terry Walsh_eyts_certificate.pdf")
    expect(page.response_headers["content-type"]).to eq("application/pdf")
    expect(page.response_headers["content-disposition"]).to include(
                                                              "attachment"
                                                            )
    expect(page.response_headers["content-disposition"]).to include(
                                                              "filename=\"Terry Walsh_eyts_certificate.pdf\";"
                                                            )
  end

  def then_i_see_my_rtps_details
    expect(page).to have_content("Route to QTLS: QTLS and SET Membership")
    expect(page).to have_content("Status\tHolds")
  end

  def then_i_see_my_npq_details
    expect(page).to have_content("National Professional Qualification (NPQ) for Headship")
    expect(page).to have_content("Held since")
    expect(page).to have_content("27 February 2023")
    expect(page).to have_content("Download NPQH certificate")
  end

  def and_my_npq_certificate_is_downloadable
    download_certificate("Download NPQH certificate", filename: "Terry Walsh_npqh_certificate.pdf")
    expect(page.response_headers["content-type"]).to eq("application/pdf")
    expect(page.response_headers["content-disposition"]).to include(
                                                              "attachment"
                                                            )
    expect(page.response_headers["content-disposition"]).to include(
                                                              "filename=\"Terry Walsh_npqh_certificate.pdf\";"
                                                            )
  end

  def then_i_see_my_mq_details
    expect(page).to have_content("Mandatory qualification (MQ)")
    expect(page).to have_content("Held since\t28 February 2023")
    expect(page).to have_content("Specialism\tVisual impairment")
  end
end
