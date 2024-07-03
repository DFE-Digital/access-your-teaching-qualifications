# frozen_string_literal: true
require "rails_helper"

RSpec.feature "Feedback", type: :system do
  include CommonSteps
  include QualificationAuthenticationSteps

  scenario "User gives feedback", test: %i[with_stubbed_auth with_fake_quals_api] do
    given_the_qualifications_service_is_open
    and_i_visit_the_start_page
    and_i_click_on_feedback
    then_i_am_prompted_to_sign_in

    and_i_am_signed_in_via_identity
    and_i_click_on_feedback
    then_i_see_the_feedback_form
    when_i_press_send_feedback
    then_i_see_validation_errors
    when_i_choose_satisfied
    when_i_fill_in_how_we_can_improve
    when_i_choose_yes
    when_i_enter_an_email
    when_i_press_send_feedback
    then_i_see_the_feedback_sent_page
    and_my_feedback_is_saved
  end

  private

  def and_i_visit_the_start_page
    visit qualifications_root_path
  end

  def and_i_click_on_feedback
    click_on "feedback"
  end

  def then_i_am_prompted_to_sign_in
    expect(page).to have_content "You need to sign in to continue"
  end

  def then_i_see_the_feedback_form
    expect(page).to have_current_path("/qualifications/feedback")
    expect(page).to have_title("Give feedback about Access your Teaching Qualifications")
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
    expect(page).to have_current_path("/qualifications/feedback/success")
    expect(page).to have_title("Feedback sent")
    expect(page).to have_content("What you can do next")
  end

  def and_my_feedback_is_saved
    expect(Feedback.where(service: "aytq").count).to eq(1)
  end
end
