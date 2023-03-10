# frozen_string_literal: true
require "rails_helper"

RSpec.feature "Identity auth", type: :system do
  include CommonSteps
  include AuthenticationSteps

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

  def then_i_am_signed_in_after_successfully_authenticating_with_identity
    expect(page).to have_content "Signed in successfully"
    expect(User.last.email).to eq "test@example.com"
  end
end
