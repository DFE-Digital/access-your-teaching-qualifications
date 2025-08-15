require 'rails_helper'

RSpec.describe "Bulk search", host: :check_records, type: :system do
  include ActivateFeaturesSteps
  include AuthenticationSteps

  scenario "User searches with a valid CSV", test: %i[with_stubbed_auth with_fake_quals_api] do
    given_the_check_service_is_open
    and_bulk_search_is_enabled
    when_i_sign_in_via_dsi
    and_search_with_a_valid_csv
    then_i_see_the_results_summary
    when_i_click_find_records
    then_i_see_results
    and_my_search_is_logged
    when_i_wait_for_the_search_to_expire
    then_i_see_the_expired_search_message
  end

  private

  def and_search_with_a_valid_csv
    click_link "Find multiple records"
    attach_file "Upload file", Rails.root.join("spec/fixtures/valid_bulk_search.csv")
    click_button "Find records"
  end

  def then_i_see_the_results_summary
    expect(page).to have_content "Your CSV file includes the details of 1 person"
  end

  def when_i_click_find_records
    click_link "Find records"
  end

  def then_i_see_results
    expect(page).to have_content "1 teacher record found"
    expect(page).to have_content "Terry Walsh"
    expect(page).to have_content "Restriction"
    expect(page).to have_content "Passed"
    expect(page).to have_selector('td[data-raw-values="Pass,"]')
  end

  def and_my_search_is_logged
    search_log = BulkSearchLog.last
    expect(search_log.csv).to eq "TRN,Date of birth\n3001403,1990-01-01\n9876543,2000-01-01\n"
    expect(search_log.query_count).to eq 2
    expect(search_log.result_count).to eq 1
  end

  def when_i_wait_for_the_search_to_expire
    travel 29.minutes
    page.refresh
    travel 2.minutes
    page.refresh
    expect(page).not_to have_content "Bulk search expired"
    travel 31.minutes
    page.refresh
  end

  def then_i_see_the_expired_search_message
    expect(page).to have_content "Bulk search expired"
    travel_back
  end 
end
