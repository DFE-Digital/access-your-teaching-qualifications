# frozen_string_literal: true
require "rails_helper"

RSpec.feature "GOVUK One Login auth", type: :system do
  include CommonSteps
  include QualificationAuthenticationSteps

  scenario "User signs in via One Login", test: %i[with_stubbed_auth with_fake_quals_api] do
    given_the_qualifications_service_is_open
    and_onelogin_auth_is_mocked
    when_i_go_to_the_sign_in_page
    and_click_the_onelogin_sign_in_button
    then_i_am_signed_in_after_successfully_authenticating_with_onelogin
    and_event_tracking_is_working
  end

  private

  def then_i_am_signed_in_after_successfully_authenticating_with_onelogin
    expect(User.last.email).to eq "test@example.com"
  end
end
