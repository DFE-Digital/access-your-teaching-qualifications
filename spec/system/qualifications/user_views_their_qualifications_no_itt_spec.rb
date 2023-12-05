require "rails_helper"

RSpec.feature "User views their qualifications", type: :system do
  include CommonSteps
  include QualificationAuthenticationSteps

  scenario "when they have no ITT", test: %i[with_stubbed_auth with_fake_quals_api] do
    given_the_service_is_open
    and_i_am_signed_in_via_identity

    when_i_visit_the_qualifications_page
    then_i_see_there_are_no_itt_details
  end

  private

  def given_identity_auth_is_mocked
    OmniAuth.config.mock_auth[:identity] = OmniAuth::AuthHash.new(
      {
        provider: "identity",
        info: {
          email: "test@example.com",
          email_verified: "True",
          first_name: "Trained",
          last_name: "Not",
          name: "Not Trained"
        },
        credentials: {
          token: "no-itt-token",
          expires_in: 1.hour.to_i
        },
        extra: {
          raw_info: {
            birthdate: "1986-01-02",
            trn: "0000000"
          }
        }
      }
    )
  end

  def then_i_see_there_are_no_itt_details
    expect(page).not_to have_content("Initial teacher training (ITT)")
  end

  def when_i_visit_the_qualifications_page
    visit qualifications_dashboard_path
  end
end
