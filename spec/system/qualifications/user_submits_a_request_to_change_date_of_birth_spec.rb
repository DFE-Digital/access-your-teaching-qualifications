# frozen_string_literal: true
require "rails_helper"

RSpec.feature "Account page", type: :system do
  include CommonSteps
  include QualificationAuthenticationSteps

  scenario "User submits a request to change date of birth", test: %i[with_stubbed_auth with_fake_quals_api] do
    given_the_qualifications_service_is_open
    given_i_am_signed_in_via_one_login
    when_i_click_through_to_update_my_details

    and_click_change_date_of_birth
    then_i_am_on_the_date_of_birth_change_form

    when_i_submit_the_form
    then_i_see_validation_errors

    # when_i_complete_the_form
    # and_i_submit_the_form
    # then_i_see_the_confirmation_page

    # when_i_edit_the_date_of_birth
    # and_i_submit_the_form
    # and_i_confirm_my_changes

    # then_my_request_is_submitted
    # and_my_evidence_is_uploaded
  end

  private

  def given_i_am_signed_in_via_one_login
    given_onelogin_authentication_is_active
    and_onelogin_auth_is_mocked
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

  def when_i_submit_the_form
    click_button "Continue"
  end
  alias_method :and_i_submit_the_form, :when_i_submit_the_form

  def then_i_see_validation_errors
    expect(page).to have_content "Date of birth must include a day and month"
    expect(page).to have_content "Select a file"
  end
end
