# frozen_string_literal: true

require "rails_helper"

RSpec.describe "DSI authentication" do
  include AuthorizationSteps
  include AuthenticationSteps

  scenario "Unauthorised user signs in via staff DfE Sign In", host: :check_records, test: :with_stubbed_auth do
    when_i_am_authorized_with_basic_auth
    when_i_sign_in_via_dsi(authorised: false)
    then_i_am_redirected_to_the_unauthorised_page
  end

  scenario "External user attempts to access support pages", host: :check_records, test: :with_stubbed_auth do
    when_i_am_authorized_with_basic_auth
    when_i_sign_in_via_dsi(authorised: true, internal: false)
    when_i_visit_the_support_interface
    then_i_see_the_not_found_page
  end

  private

  def then_i_am_redirected_to_the_unauthorised_page
    expect(page).to have_current_path("/check-records/not-authorised")
    expect(page).to have_content("You cannot use the DfE Sign-in account for Test Org to check a teacher’s record")
    expect(page).to have_link("sign out and start again", href: "/check-records/auth/dfe/sign-out?id_token_hint=abc123")

    within(".govuk-header__content") do
      expect(page).not_to have_link("Features")
      expect(page).not_to have_link("Staff")
      expect(page).not_to have_link("Sign in")
      expect(page).not_to have_link("Sign out")
    end
  end

  def when_i_visit_the_support_interface
    visit "/support"
  end

  def then_i_see_the_not_found_page
    expect(page).to have_content("Page not found")
  end
end
