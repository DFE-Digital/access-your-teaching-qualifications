# frozen_string_literal: true

require "rails_helper"

RSpec.describe "DSI authentication", host: :check_records, type: :system do
  include ActivateFeaturesSteps
  include AuthenticationSteps

  scenario "User belonging to closed organisation signs in via DfE Sign In", test: :with_stubbed_auth do
    given_the_check_service_is_open
    when_i_sign_in_via_dsi(orgs: [organisation(status: "Closed")], accept_terms_and_conditions: false)
    then_i_am_not_authorised
  end

  private

  def then_i_am_not_authorised
    expect(page).to have_content(
      "You cannot use the DfE Sign-in account for Test Org to check a teacher’s record"
    )
    expect(page).to have_link("sign out and start again", href: "/check-records/auth/dfe/sign-out?id_token_hint=abc123")
  end
end
