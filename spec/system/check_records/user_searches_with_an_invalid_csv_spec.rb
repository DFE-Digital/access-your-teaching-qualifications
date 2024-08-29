require 'rails_helper'

RSpec.describe "Bulk search", host: :check_records, type: :system do
  include ActivateFeaturesSteps
  include AuthenticationSteps

  scenario "User searches with an invalid CSV", test: %i[with_stubbed_auth with_fake_quals_api] do
    given_the_check_service_is_open
    and_bulk_search_is_enabled
    when_i_sign_in_via_dsi
    and_search_with_a_csv_missing_headers
    then_i_see_the_template_error_message

    when_i_search_with_a_csv_missing_a_value
    then_i_see_the_missing_value_error_message
  end

  private

  def and_search_with_a_csv_missing_headers
    click_link "Find multiple records"
    attach_file "Upload file", Rails.root.join("spec/fixtures/invalid_bulk_search.csv")
    click_button "Find records"
  end

  def then_i_see_the_template_error_message
    expect(page).to have_content "The selected file must use the template"
  end

  def when_i_search_with_a_csv_missing_a_value
    attach_file "Upload file", Rails.root.join("spec/fixtures/invalid_bulk_search_missing_trn.csv")
    click_button "Find records"
  end

  def then_i_see_the_missing_value_error_message
    expect(page).to have_content "The selected file does not have a TRN in row 1"
  end
end

