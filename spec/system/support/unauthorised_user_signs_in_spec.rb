# frozen_string_literal: true

require "rails_helper"

RSpec.describe "DSI authentication" do
  include AuthorizationSteps
  include AuthenticationSteps

  scenario "Unauthorised user signs in via staff DfE Sign In", test: :with_stubbed_auth do
    when_i_am_authorized_with_basic_auth
    when_i_sign_in_via_dsi(authorised: false)
    then_i_am_redirected_to_the_unauthorised_page
  end

  private

  def then_i_am_redirected_to_the_unauthorised_page
    expect(page).to have_current_path("/support/not-authorised")
    expect(page).to have_content("You cannot use the DfE Sign-in account for Test Org to access the support interface")
    expect(page).to have_link("sign out and start again", href: "/support/auth/staff/sign-out?id_token_hint=abc123")

    within(".govuk-header__content") do
      expect(page).not_to have_link("Sign in")
      expect(page).not_to have_link("Sign out")
    end
  end
end
