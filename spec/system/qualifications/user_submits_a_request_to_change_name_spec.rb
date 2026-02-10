# frozen_string_literal: true
require "rails_helper"

RSpec.feature "Account page", type: :system do
  include CommonSteps
  include QualificationAuthenticationSteps
  include MalwareScanHelpers

  scenario "User submits a request to change name", test: %i[with_stubbed_auth with_fake_quals_api] do
    given_the_qualifications_service_is_open
    given_i_am_signed_in_via_one_login
    given_malware_scanning_is_enabled
    when_i_click_through_to_update_my_details
    and_click_change_name
    then_i_am_on_the_name_change_form
    and_i_can_see_a_list_of_valid_evidence
    when_i_submit_the_form
    then_i_see_validation_errors

    when_i_complete_the_form
    and_i_submit_the_form
    then_i_see_the_confirmation_page

    when_i_edit_my_name
    and_i_submit_the_form
    and_i_confirm_my_changes

    then_my_request_is_submitted
    and_my_evidence_is_uploaded

    when_the_pending_scan_result_is_fetched_after_a_delay
    then_the_evidence_is_updated
  end

  private

  def given_i_am_signed_in_via_one_login
    given_onelogin_auth_is_mocked
    when_i_go_to_the_sign_in_page
    and_click_the_onelogin_sign_in_button
  end

  def when_i_click_through_to_update_my_details
    click_link "View and update details"
  end

  def and_click_change_name
    change_links = all('a', text: 'Change')
    change_links[0].click
  end

  def then_i_am_on_the_name_change_form
    expect(page).to have_content "Change your name on teaching certificates"
  end

  def and_i_can_see_a_list_of_valid_evidence
    expect(page).to have_selector(:css, "li", text: "deed poll", visible: :all)
  end

  def when_i_submit_the_form
    click_button "Continue"
  end
  alias_method :and_i_submit_the_form, :when_i_submit_the_form

  def then_i_see_validation_errors
    expect(page).to have_content "Enter your first name"
    expect(page).to have_content "Enter your last name"
    expect(page).to have_content "Select a file"
  end

  def when_i_complete_the_form
    fill_in "First name", with: " Steven"
    fill_in "Middle name", with: " Gonville "
    fill_in "Last name", with: "Toast"

    attach_file "Upload evidence", Rails.root.join("spec/fixtures/test-upload.pdf")
  end

  def then_i_see_the_confirmation_page
    expect(page).to have_content "Confirm change"
    expect(page).to have_content "Steven Gonville Toast"
    expect(page).to have_content "test-upload.pdf"
  end

  def when_i_edit_my_name
    change_links = all('a', text: 'Change')
    change_links[0].click
    fill_in "First name", with: "Ray"
    fill_in "Middle name", with: ""
    fill_in "Last name", with: "Purchase"

    attach_file "Upload evidence", Rails.root.join("spec/fixtures/test-upload.pdf")
  end

  def and_i_confirm_my_changes
    click_button "Continue"
  end

  def then_my_request_is_submitted
    expect(NameChange.last.full_name).to eq "Ray Purchase"
    expect(NameChange.last.reference_number).to eq "CASE-TEST-123"
    expect(page).to have_content "Name change request submitted"
    expect(page).to have_content "CASE-TEST-123"
  end

  def and_my_evidence_is_uploaded
    expect(NameChange.last.evidence.attached?).to be true
    expect(NameChange.last.malware_scan_result).to eq "pending"
  end

  def when_the_pending_scan_result_is_fetched_after_a_delay
    time = Time.zone.now + 1.minute
    travel_to(time) { perform_enqueued_jobs(only: FetchMalwareScanResultJob) }
  end

  def then_the_evidence_is_updated
    expect(NameChange.last.malware_scan_result).to eq "clean"
  end
end
