require "rails_helper"

RSpec.feature "Handling null data", type: :system do
  include CommonSteps
  include QualificationAuthenticationSteps

  scenario(
    "User views qualifications with missing data",
    test: %i[with_stubbed_auth with_fake_quals_api]
  ) do
    given_the_qualifications_service_is_open
    and_i_am_signed_in_via_identity_as_a_user_with_partial_quals_data

    when_i_visit_the_qualifications_page
    then_it_renders
  end

  private

  def and_i_am_signed_in_via_identity_as_a_user_with_partial_quals_data
    given_identity_auth_is_mocked
    OmniAuth.config.mock_auth[:identity].credentials.token = "nulled-quals-data"
    when_i_go_to_the_sign_in_page
    and_click_the_sign_in_button
  end

  def when_i_visit_the_qualifications_page
    visit qualifications_dashboard_path
  end

  def then_it_renders
    expect(page).to have_content "Teaching qualifications"
    expect(page).to have_content "Terry"
    expect(page).to have_content "QTS"
  end
end
