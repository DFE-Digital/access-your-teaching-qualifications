# frozen_string_literal: true

require "rails_helper"

RSpec.describe "DSI authentication", host: :check_records do
  include AuthorizationSteps
  include CheckRecords::AuthenticationSteps

  scenario "Unauthorised user signs in via DfE Sign In", test: :with_stubbed_auth do
    when_i_am_authorized_with_basic_auth
    when_i_sign_in_via_dsi(authorised: false)
    then_i_am_redirected_to_the_unauthorised_page
  end

  private

  def then_i_am_redirected_to_the_unauthorised_page
    expect(page).to have_current_path("/check-records/not-authorised")
    expect(page).to have_content("You are not authorised to access this service")
  end
end
