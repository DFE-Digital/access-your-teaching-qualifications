# frozen_string_literal: true

require "rails_helper"

RSpec.describe "TRN search", host: :check_records, type: :system do
  include ActivateFeaturesSteps
  include CheckRecords::AuthenticationSteps

  scenario "User searches with a trn and finds a records",
           test: %i[with_stubbed_auth with_fake_quals_api] do
    given_the_service_is_open
    when_i_sign_in_via_dsi
    and_search_with_a_valid_trn
    then_i_see_a_teacher_record
  end

  private

  def and_search_with_a_valid_trn
    fill_in "trn", with: "1234567"
    click_button "Search"
  end

  def then_i_see_a_teacher_record
    expect(page).to have_content "Terry Walsh"
  end
end
