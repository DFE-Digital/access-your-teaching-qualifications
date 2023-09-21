require "rails_helper"

RSpec.feature "Staff support", type: :system do
  include CommonSteps

  scenario "Staff changes password" do
    given_the_service_is_open
    and_a_staff_user_exists

    when_i_visit_the_staff_page
    then_i_see_the_staff_sign_in_page

    when_i_click_on_forgot_password
    then_i_see_the_forgot_password_page

    when_i_fill_email_address
    and_i_submit_the_form
    then_i_see_a_password_change_email
    when_i_click_the_change_password_link
    and_i_fill_password
    and_i_set_password
    then_i_see_the_support_interface
  end

  private

  def and_a_staff_user_exists
    create(:staff, :confirmed)
  end

  def when_i_visit_the_staff_page
    visit new_staff_session_path
  end

  def when_i_click_the_change_password_link
    message = ActionMailer::Base.deliveries.first
    uri = URI.parse(URI.extract(message.body.to_s).first)
    expect(uri.path).to eq("/staff/password/edit")
    expect(uri.query).to include("reset_password_token=")
    visit "#{uri.path}?#{uri.query}"
  end

  def when_i_click_on_forgot_password
    click_link "Forgot your password?"
  end

  def when_i_fill_email_address
    fill_in "Email", with: "staff@example.com"
  end

  def and_i_submit_the_form
    click_button "Send me reset password instructions", visible: false
  end

  def then_i_see_the_forgot_password_page
    expect(page).to have_current_path("/staff/password/new")
  end

  def then_i_see_the_staff_sign_in_page
    expect(page).to have_current_path("/staff/sign_in")
    expect(page).to have_content("Log in")
  end

  def then_i_see_a_password_change_email
    perform_enqueued_jobs
    message = ActionMailer::Base.deliveries.first
    expect(message).to_not be_nil

    expect(message.subject).to eq("Reset password instructions")
    expect(message.to).to include("staff@example.com")
  end

  def and_i_fill_password
    fill_in "staff-password-field", with: "password"
    fill_in "staff-password-confirmation-field", with: "password"
  end

  def and_i_set_password
    click_button "Change my password", visible: false
  end
  
  def then_i_see_the_support_interface
    expect(page).to have_current_path("/support")
    expect(page).to have_content("Support Interface")
  end
end

