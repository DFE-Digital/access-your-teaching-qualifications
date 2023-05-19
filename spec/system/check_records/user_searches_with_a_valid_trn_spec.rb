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

    then_i_see_my_induction_details
    then_i_see_my_qts_details
    then_i_see_my_itt_details
    then_i_see_my_eyts_details
    then_i_see_my_npq_details
    then_i_see_my_mq_details
  end

  private

  def and_search_with_a_valid_trn
    fill_in "trn", with: "1234567"
    click_button "Search"
  end

  def then_i_see_a_teacher_record
    expect(page).to have_content "Terry Walsh"
  end

  def then_i_see_my_induction_details
    expect(page).to have_content("Induction")
    expect(page).to have_content("Pass")
    expect(page).to have_content("1 October 2022")
  end

  def then_i_see_my_qts_details
    expect(page).to have_content("Qualified teacher status (QTS)")
    expect(page).to have_content("Date awarded")
    expect(page).to have_content("27 February 2023")
  end

  def then_i_see_my_eyts_details
    expect(page).to have_content("Early years teacher status (EYTS)")
    expect(page).to have_content("Date awarded")
    expect(page).to have_content("27 February 2023")
  end

  def then_i_see_my_itt_details
    expect(page).to have_content("Initial teacher training (ITT)")
    expect(page).to have_content("BA")
    expect(page).to have_content("Earl Spencer Primary School")
    expect(page).to have_content("HEI")
    expect(page).to have_content("Business Studies")
    expect(page).to have_content("28 January 2023")
    expect(page).to have_content("Pass")
    expect(page).to have_content("10 to 16 years")
  end

  def then_i_see_my_npq_details
    expect(page).to have_content("Date NPQ headteacher awarded")
    expect(page).to have_content("27 February 2023")
  end

  def then_i_see_my_mq_details
    expect(page).to have_content("Mandatory qualification (MQ)")
    expect(page).to have_content("Date awarded\t28 February 2023")
    expect(page).to have_content("Specialism\tVisual impairment")
  end
end
