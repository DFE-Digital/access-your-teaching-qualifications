# frozen_string_literal: true

require "rails_helper"

RSpec.describe "DSI authentication", host: :check_records do
  include AuthorizationSteps
  include AuthenticationSteps

  scenario "User signs out", test: :with_stubbed_auth do
    when_i_am_authorized_with_basic_auth
    and_i_am_signed_in_via_dsi
    when_i_sign_out
    then_i_am_redirected_to_the_sign_in_page
  end

  private

  def when_i_sign_out
    click_on "Sign out"
  end

  def then_i_am_redirected_to_the_sign_in_page
    expect(page).to have_current_path(ENV.fetch("CHECK_RECORDS_GUIDANCE_URL"))
  end
end
