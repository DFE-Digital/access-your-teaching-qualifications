# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Terms and conditions acceptance", host: :check_records do
  include AuthorizationSteps
  include AuthenticationSteps
  include ActivateFeaturesSteps

  scenario "User accepts terms and conditions", test: :with_stubbed_auth do
    given_the_check_service_is_open
    when_i_sign_in_via_dsi(accept_terms_and_conditions: false)
    then_i_am_signed_in
    and_i_am_redirected_to_the_terms_and_conditions_page

    when_i_click_accept
    then_i_am_taken_to_the_root
    and_i_see_the_successful_notification
    and_the_dsi_user_has_been_updated

    when_13_months_has_passed
    when_i_go_to_the_root
    when_i_sign_in_via_dsi(accept_terms_and_conditions: false)
    then_i_am_redirected_to_the_terms_and_conditions_page
    when_i_click_accept
    then_i_am_taken_to_the_root
    and_i_see_the_successful_notification
  end

  private

  def then_i_am_signed_in
    within("#navigation") { expect(page).to have_content "Sign out" }
    expect(DsiUser.count).to eq 1
    expect(DsiUserSession.count).to eq 1
  end

  def and_i_am_redirected_to_the_terms_and_conditions_page
    expect(page).to have_current_path("/check-records/terms-and-conditions")
  end
  alias_method(
    :then_i_am_redirected_to_the_terms_and_conditions_page,
    :and_i_am_redirected_to_the_terms_and_conditions_page,
  )

  def and_i_click_on_terms_and_conditions_footer_link
    click_link "Terms and conditions"
  end

  def and_the_accept_button_is_hidden
    expect(page).not_to have_link "Accept"
  end

  def when_i_click_accept
    click_on "Accept"
  end

  def then_i_am_taken_to_the_root
    expect(page).to have_current_path("/check-records/search")
  end

  def and_i_see_the_successful_notification
    expect(page).to have_content "Terms and conditions accepted"
  end

  def and_the_dsi_user_has_been_updated
    expect(DsiUser.first.terms_and_conditions_version_accepted).to eq("1.0")
    expect(DsiUser.first.terms_and_conditions_accepted_at).to_not be(nil)
  end

  def when_13_months_has_passed
    travel_to 13.months.from_now
  end

  def when_i_go_to_the_root
    visit check_records_root_path
  end
end
