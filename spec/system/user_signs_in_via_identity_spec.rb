# frozen_string_literal: true
require "rails_helper"

RSpec.feature "Identity auth", type: :system do
  include CommonSteps

  around do |example|
    OmniAuth.config.test_mode = true
    example.run
    OmniAuth.config.test_mode = false
    OmniAuth.config.mock_auth[:identity] = nil
  end

  scenario "User signs in via Identity" do
    given_the_service_is_open
    and_identity_auth_is_mocked
    when_i_go_to_the_sign_in_page
    and_click_the_sign_in_button
    then_i_am_signed_in_after_successfully_authenticating_with_identity
  end

  private

  def and_identity_auth_is_mocked
    OmniAuth.config.mock_auth[:identity] = OmniAuth::AuthHash.new(
      {
        provider: "identity",
        info: {
          email: "test@example.com",
          name: "Test User",
          given_name: "Test",
          family_name: "User",
          trn: "123456",
          date_of_birth: "1986-01-02"
        },
        credentials: {
          token: SecureRandom.hex
        }
      }
    )
  end

  def when_i_go_to_the_sign_in_page
    visit sign_in_path
  end

  def and_click_the_sign_in_button
    click_button "Sign in with Identity"
  end

  def then_i_am_signed_in_after_successfully_authenticating_with_identity
    expect(page).to have_content "Signed in successfully"
    expect(User.last.email).to eq "test@example.com"
  end
end
