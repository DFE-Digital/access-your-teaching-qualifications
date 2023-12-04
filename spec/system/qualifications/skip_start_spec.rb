require "rails_helper"

RSpec.feature "Skipping the qualifications start page", type: :system do
  include CommonSteps

  scenario "when a user visits the start page path", test: :with_stubbed_auth do
    given_the_qualifications_service_is_open
    and_omniauth_request_phase_provides_a_valid_redirect

    when_i_visit_the_qualifications_start_page
    then_i_am_redirected_to_the_identity_service
  end

  private

  def and_omniauth_request_phase_provides_a_valid_redirect
    allow_any_instance_of(Qualifications::StartsController)
      .to receive(:identity_api_domain).and_return("http://www.example.com")

    stub_request(:post, identity_service_auth_url)
      .to_return(status: 302, headers: { "location" => fake_identity_service_location })
  end

  def when_i_visit_the_qualifications_start_page
    visit qualifications_start_path
  end

  def then_i_am_redirected_to_the_identity_service
    expect(page).to have_current_path(fake_identity_service_location)
  end

  def identity_service_auth_url
    %(#{ENV["HOSTING_DOMAIN"]}/qualifications/users/auth/identity?trn_token=)
  end

  def fake_identity_service_location
    "http://www.example.com/fake-identity-service"
  end
end
