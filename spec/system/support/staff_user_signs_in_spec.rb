# frozen_string_literal: true

require "rails_helper"

RSpec.describe "DSI authentication" do
  include AuthorizationSteps
  include AuthenticationSteps

  scenario "Staff user signs in via DfE Sign In", host: :check_records, test: :with_stubbed_auth do
    when_i_am_authorized_with_basic_auth
    when_i_sign_in_as_staff_via_dsi
    then_i_am_signed_in
  end

  private

  def then_i_am_signed_in
    within("header") do
      expect(page).to have_link("Features")
      expect(page).to have_content "Sign out"
    end
    expect(DsiUser.count).to eq 1
    expect(DsiUserSession.count).to eq 1
  end
end
