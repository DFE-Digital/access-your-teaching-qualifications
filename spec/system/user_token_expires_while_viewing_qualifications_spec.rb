require "rails_helper"

RSpec.feature "Identity auth", type: :system do
  include CommonSteps
  include AuthenticationSteps

  after { travel_back }

  scenario "Access token expires while viewing qualifications", test: :with_stubbed_auth do
    given_the_service_is_open
    and_i_am_signed_in_via_identity

    when_i_visit_the_qualifications_page
    and_my_access_token_expires
    and_i_try_to_download_a_certificate
    then_i_am_required_to_sign_in_again
  end

  private

  def when_i_visit_the_qualifications_page
    visit qualifications_path
  end

  def and_my_access_token_expires
    travel_to Time.zone.now + 61.minutes
  end

  def and_i_try_to_download_a_certificate
    click_on "Download QTS certificate"
  end

  def then_i_am_required_to_sign_in_again
    expect(page).to have_content "Your session has expired. Please sign in again."
  end
end
