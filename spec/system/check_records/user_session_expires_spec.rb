require "rails_helper"

RSpec.feature "DSI session expiry", host: :check_records, type: :system do
  include CommonSteps
  include CheckRecords::AuthenticationSteps

  after { travel_back }

  scenario "Session expires", test: :with_stubbed_auth do
    given_the_service_is_open
    and_i_am_signed_in_via_dsi
    and_my_session_expires
    when_i_refresh_the_page
    then_i_am_required_to_sign_in_again
  end

  private

  def and_my_session_expires
    travel_to 121.minutes.from_now
  end

  def then_i_am_required_to_sign_in_again
    expect(page).to have_content "Your session has expired. Please sign in again."
  end

  def when_i_refresh_the_page
    page.refresh
  end
end
