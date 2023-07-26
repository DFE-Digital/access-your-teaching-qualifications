# frozen_string_literal: true

require "rails_helper"

RSpec.describe "DSI authentication", host: :check_records, type: :system do
  include AuthorizationSteps
  include CheckRecords::AuthenticationSteps

  before do
    when_i_am_authorized_with_basic_auth
    allow(Sentry).to receive(:capture_exception)
  end

  scenario "User has oauth error when signing in", test: :with_stubbed_auth do
    given_dsi_auth_is_mocked_with_a_failure
    when_i_visit_the_sign_in_page
    and_click_the_dsi_sign_in_button
    then_i_see_a_sign_in_error
  end

  private

  def given_dsi_auth_is_mocked_with_a_failure
    OmniAuth.config.mock_auth[:dfe] = :invalid_credentials
  end

  def then_i_see_a_sign_in_error
    expect(page).to have_content "There was a problem signing you in. Please try again."
  end
end
