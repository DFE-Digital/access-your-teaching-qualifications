# frozen_string_literal: true
require "rails_helper"

RSpec.feature "Account page", type: :system do
  include CommonSteps
  include QualificationAuthenticationSteps

  scenario "User views their account page", test: %i[with_stubbed_auth with_fake_quals_api] do
    given_the_qualifications_service_is_open
    and_onelogin_auth_is_mocked
    when_i_go_to_the_sign_in_page
    and_click_the_onelogin_sign_in_button
    then_i_see_my_qualifications_page
    when_i_click_through_to_update_my_details
    then_i_see_my_account_page
  end

  private

  def then_i_see_my_qualifications_page
    expect(page).to have_current_path qualifications_dashboard_path
  end

  def when_i_click_through_to_update_my_details
    click_link "View and update details"
  end

  def then_i_see_my_account_page
    expect(page).to have_content "Change your details"
    expect(page).to have_content "GOV.UK One Login security details"
  end
end
