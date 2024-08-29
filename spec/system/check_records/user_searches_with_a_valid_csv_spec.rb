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
  end

  private

  def and_search_with_a_valid_csv
    click_link "Find multiple records"
    attach_file "Upload file", Rails.root.join("spec/fixtures/valid_bulk_search.csv")
    click_button "Find records"
  end

  def then_i_see_the_results_summary
    expect(page).to have_content "1 teacher record found"
  end
end
