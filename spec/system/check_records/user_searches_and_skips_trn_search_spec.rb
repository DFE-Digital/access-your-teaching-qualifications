# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Teacher search", host: :check_records, type: :system do
  include ActivateFeaturesSteps
  include AuthenticationSteps

  scenario "User searches and skips TRN page",
           test: %i[with_stubbed_auth with_fake_quals_api] do
    given_the_check_service_is_open
    given_the_trn_search_feature_is_active
    when_i_sign_in_via_dsi
    and_search_with_a_valid_name_and_dob
    then_i_am_prompted_to_enter_trn

    when_i_skip_the_trn_search
    then_i_see_multiple_search_results
    and_search_logs_are_created
  end

  private

  def given_the_trn_search_feature_is_active
    FeatureFlags::FeatureFlag.activate(:trn_search)
  end

  def and_search_with_a_valid_name_and_dob
    fill_in "Last name", with: "Multiple_results"
    fill_in "Day", with: "5"
    fill_in "Month", with: "April"
    fill_in "Year", with: "1992"
    click_button "Find record"
  end

  def and_search_with_a_valid_name_and_dob
    fill_in "Last name", with: "Multiple_results"
    fill_in "Day", with: "5"
    fill_in "Month", with: "April"
    fill_in "Year", with: "1992"
    click_button "Find record"
  end

  def then_i_am_prompted_to_enter_trn
    expect(page).to have_content "Multiple results found"
    expect(page).to have_content "Enter a teacher reference number"
  end

  def when_i_skip_the_trn_search
    click_link "Skip"
  end

  def then_i_see_multiple_search_results
    expect(page).to have_content "2 records found"
    expect(page).to have_content "you must only view the teacher record you need"
  end

  def and_search_logs_are_created
    expect(SearchLog.order(created_at: :asc).pluck(:search_type)).to eq(
      %w[personal_details skip_trn_use_personal_details]
    )
  end
end
