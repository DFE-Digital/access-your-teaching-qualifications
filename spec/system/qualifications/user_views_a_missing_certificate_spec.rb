require "rails_helper"

RSpec.feature "User views their certificates", type: :system do
  include CommonSteps
  include QualificationAuthenticationSteps

  scenario "when a certificate is missing",
           test: %i[with_stubbed_auth with_fake_quals_api] do
    given_the_qualifications_service_is_open
    and_i_am_signed_in_via_identity

    when_i_visit_the_qualifications_page
    and_my_npqsl_certificate_is_missing
    then_i_see_the_dashboard_with_a_missing_certificate_alert
  end

  private

  def when_i_visit_the_qualifications_page
    visit qualifications_dashboard_path
  end

  def and_my_npqsl_certificate_is_missing
    click_on "Download NPQSL certificate"
  end

  def then_i_see_the_dashboard_with_a_missing_certificate_alert
    expect(page).to have_content("Certificate not found")
  end
end
