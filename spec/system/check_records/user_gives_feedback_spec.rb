# frozen_string_literal: true
require "rails_helper"

RSpec.feature "Feedback", host: :check_records, type: :system do
  include ActivateFeaturesSteps
  include AuthenticationSteps

  scenario "User gives feedback", test: :with_stubbed_auth do
    given_the_check_service_is_open
    and_i_am_an_existing_dsi_user
    when_i_visit_the_sign_in_page
    and_i_click_on_feedback
    then_i_am_prompted_to_sign_in
    when_i_sign_in_via_dsi(accept_terms_and_conditions: false)
    then_i_see_the_feedback_form
    when_i_press_send_feedback
    then_i_see_validation_errors
    when_i_choose_satisfied
    then_i_see_validation_errors
    when_i_fill_in_how_we_can_improve
    then_i_see_validation_errors
    when_i_choose_yes
    then_i_see_validation_errors
    when_i_enter_an_email
    when_i_press_send_feedback
    then_i_see_the_feedback_sent_page
  end

  private

  def and_i_am_an_existing_dsi_user
    create(
      :dsi_user, 
      email: "test@example.com", 
      terms_and_conditions_accepted_at: Date.yesterday, 
      terms_and_conditions_version_accepted: '1.0'
    )
  end

  def and_i_visit_the_search_page
    visit search_path
  end

  def and_i_click_on_feedback
    click_on "feedback"
  end

  def then_i_am_prompted_to_sign_in
    expect(page).to have_current_path("/check-records/sign-in")
    expect(page).to have_content("You must be signed in to give feedback.")
  end

  def then_i_see_the_feedback_form
    expect(page).to have_current_path("/check-records/feedback")
    expect(page).to have_title("Give feedback about checking the record of a teacher")
    expect(page).to have_content("How satisfied are you with the service?")
  end

  def when_i_press_send_feedback
    click_on "Send feedback"
  end

  def then_i_see_validation_errors
    expect(page).to have_content("There’s a problem")
  end

  def when_i_choose_satisfied
    choose "Satisfied", visible: false
  end

  def when_i_fill_in_how_we_can_improve
    fill_in "How can we improve the service?", with: "Make it better"
  end

  def when_i_choose_yes
    choose "Yes", visible: false
  end

  def when_i_enter_an_email
    fill_in "Email address", with: "my_email@example.com"
  end

  def then_i_see_the_feedback_sent_page
    expect(page).to have_current_path("/check-records/feedback/success")
    expect(page).to have_title("Feedback sent")
    expect(page).to have_content("What you can do next")
  end
end
