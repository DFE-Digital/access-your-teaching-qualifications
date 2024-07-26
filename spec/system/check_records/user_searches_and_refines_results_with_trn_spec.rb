# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Teacher search", host: :check_records, type: :system do
  include ActivateFeaturesSteps
  include AuthenticationSteps

  scenario "User searches and refines results with a TRN",
           test: %i[with_stubbed_auth with_fake_quals_api] do
    given_the_check_service_is_open
    given_the_trn_search_feature_is_active
    when_i_sign_in_via_dsi
    and_search_with_a_valid_name_and_dob
    then_i_am_prompted_to_enter_trn

    when_i_submit_the_form
    then_i_see_an_error

    when_i_enter_a_trn
    and_i_submit_the_form
    then_i_see_a_teacher_record_in_the_results

    when_i_click_on_the_teacher_record
    then_i_see_this_teachers_details
    and_search_logs_are_created
  end

  private

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

  def when_i_submit_the_form
    click_button "Find record"
  end
  alias_method :and_i_submit_the_form, :when_i_submit_the_form

  def then_i_see_an_error
    expect(page).to have_content "Enter a valid TRN"
  end

  def when_i_enter_a_trn
    fill_in "TRN", with: "1234567"
  end

  def then_i_see_a_teacher_record_in_the_results
    expect(page).to have_content "Terry John Walsh"
  end

  def when_i_click_on_the_teacher_record
    click_on "Terry John Walsh"
  end

  def then_i_see_this_teachers_details
    expect(page).to have_content "Terry Walsh"
    expect(page).to have_content "1234567"
    expect(page).to have_content "January 01, 2000"
    expect(page).to have_content "QTS"
  end

  def and_search_logs_are_created
    expect(SearchLog.order(created_at: :asc).pluck(:search_type)).to eq %w[personal_details trn]
    expect(SearchLog.last.result_count).to eq 1
  end
end
