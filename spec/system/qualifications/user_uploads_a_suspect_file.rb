# frozen_string_literal: true
require "rails_helper"

RSpec.feature "Account page", type: :system do
  include CommonSteps
  include QualificationAuthenticationSteps
  include MalwareScanHelpers

  scenario "User submits a request to change date of birth", test: %i[with_stubbed_auth with_fake_quals_api] do
    given_the_qualifications_service_is_open
    given_i_am_signed_in_via_one_login
    given_malware_scanning_is_enabled(scan_result: "Malicious")
    when_i_click_through_to_update_my_details

    and_click_change_date_of_birth
    then_i_am_on_the_date_of_birth_change_form
    and_i_can_see_a_list_of_valid_evidence

    when_i_submit_the_form
    then_i_see_validation_errors

    when_i_complete_the_form
    and_i_submit_the_form
    then_i_see_the_confirmation_page

    when_i_edit_the_date_of_birth
    and_i_submit_the_form
    and_i_confirm_my_changes

    then_my_request_is_submitted
    and_my_evidence_is_uploaded

    when_the_pending_scan_result_is_fetched_after_a_delay
    then_the_evidence_is_flagged_as_suspicious

    when_the_remove_file_job_runs_after_a_delay
    then_the_evidence_is_removed
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

  def and_click_change_date_of_birth
    change_links = all('a', text: 'Change')
    change_links[1].click
  end

  def then_i_am_on_the_date_of_birth_change_form
    expect(page).to have_content "Change your date of birth"
  end

  def and_i_can_see_a_list_of_valid_evidence
    within(".govuk-details") do
      expect(page).to have_selector(:css, "li", text: "driving license", visible: :all)
    end
  end

  def when_i_submit_the_form
    click_button "Continue"
  end
  alias_method :and_i_submit_the_form, :when_i_submit_the_form

  def then_i_see_validation_errors
    expect(page).to have_content "Enter a date of birth"
    expect(page).to have_content "Select a file"
  end

  def when_i_complete_the_form
    fill_in("Day", with: 5)
    fill_in("Month", with: 12)
    fill_in("Year", with: 1990)

    attach_file "Upload evidence", Rails.root.join("spec/fixtures/test-upload.pdf")
  end

  def then_i_see_the_confirmation_page
    expect(page).to have_content "Confirm change"
    expect(page).to have_content "5 December 1990"
    expect(page).to have_content "test-upload.pdf"
  end

  def when_i_edit_the_date_of_birth
    change_links = all('a', text: 'Change')
    change_links[0].click
    fill_in "Month", with: 3

    attach_file "Upload evidence", Rails.root.join("spec/fixtures/test-upload.pdf")
  end

  def and_i_confirm_my_changes
    click_button "Continue"
  end

  def then_my_request_is_submitted
    expect(page).to have_content "Date of birth change request submitted"
    expect(page).to have_content "CASE-TEST-123"
    expect(DateOfBirthChange.last.date_of_birth.to_s).to eq "1990-03-05"
    expect(DateOfBirthChange.last.reference_number).to eq "CASE-TEST-123"
  end

  def and_my_evidence_is_uploaded
    expect(DateOfBirthChange.last.evidence.attached?).to be true
    expect(DateOfBirthChange.last.malware_scan_result).to eq "pending"
  end

  def when_the_pending_scan_result_is_fetched_after_a_delay
    time = Time.zone.now + 1.minute
    travel_to(time) { perform_enqueued_jobs(only: FetchMalwareScanResultJob) }
  end

  def then_the_evidence_is_flagged_as_suspicious
    expect(DateOfBirthChange.last.malware_scan_result).to eq "suspect"
  end

  def when_the_remove_file_job_runs_after_a_delay
    time = Time.zone.now + 1.minute
    travel_to(time) { perform_enqueued_jobs(only: RemoveMalwareFileJob) }
  end

  def then_the_evidence_is_removed
    expect(DateOfBirthChange.last.evidence.attached?).to be false
  end
end
