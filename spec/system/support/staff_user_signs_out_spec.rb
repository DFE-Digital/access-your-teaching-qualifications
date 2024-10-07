# frozen_string_literal: true

require "rails_helper"

RSpec.describe "DSI authentication" do
  include AuthorizationSteps
  include AuthenticationSteps

  scenario "Staff user signs out", host: :check_records, test: :with_stubbed_auth do
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
