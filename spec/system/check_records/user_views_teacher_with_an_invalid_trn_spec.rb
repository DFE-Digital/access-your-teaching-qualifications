# frozen_string_literal: true

require "rails_helper"

RSpec.describe "TRN search", host: :check_records, type: :system do
  include ActivateFeaturesSteps
  include AuthenticationSteps

  scenario "User tries to view a teacher with invalid TRN",
           test: %i[with_stubbed_auth with_fake_quals_api] do
    given_the_check_service_is_open
    when_i_sign_in_via_dsi
    and_view_a_teacher_with_an_invalid_trn
    then_i_see_a_not_found_page
  end

  # A plain TRN must not bypass the last name and date of birth search.
  # Whether it fails Base64 decoding or decryption depends on its last digit.
  scenario "User tries to view a teacher with a plain TRN that isn't valid Base64",
           test: %i[with_stubbed_auth with_fake_quals_api] do
    given_the_check_service_is_open
    when_i_sign_in_via_dsi
    and_view_a_teacher_by_plain_trn("1234567")
    then_i_see_a_not_found_page
  end

  scenario "User tries to view a teacher with a plain TRN that is valid Base64",
           test: %i[with_stubbed_auth with_fake_quals_api] do
    given_the_check_service_is_open
    when_i_sign_in_via_dsi
    and_view_a_teacher_by_plain_trn("1234560")
    then_i_see_a_not_found_page
  end

  private

  def and_view_a_teacher_with_an_invalid_trn
    visit check_records_teacher_path("bad-trn")
  end

  def and_view_a_teacher_by_plain_trn(trn)
    visit check_records_teacher_path(trn)
  end

  def then_i_see_a_not_found_page
    expect(page).to have_content "Teacher not found"
    expect(page).to have_title "Teacher not found - Check a teacher’s record"
  end
end
