require "rails_helper"

RSpec.feature "Staff sign out" do
  include CommonSteps

  scenario "Staff user signs out" do
    given_the_service_is_open
    and_a_staff_user_exists
    when_i_visit_the_support_interface
    then_i_see_the_staff_login_page
    when_i_enter_my_credentials
    and_i_click_on_the_login_button
    then_i_see_the_support_interface

    when_i_click_the_sign_out_link
    then_i_see_the_signed_out_notice
  end

  def and_a_staff_user_exists
    @staff_user = create(:staff, :confirmed)
  end

  def then_i_see_the_staff_login_page
    expect(page).to have_content("Log in")
  end

  def when_i_enter_my_credentials
    fill_in "Email", with: @staff_user.email
    fill_in "Password", with: "password"
  end

  def and_i_click_on_the_login_button
    click_on "Log in"
  end

  def then_i_see_the_support_interface
    expect(page).to have_content("Support")
  end

  def when_i_click_the_sign_out_link
    click_on "Sign out"
  end

  def then_i_see_the_signed_out_notice
    expect(page).to have_content("Signed out successfully.")
  end
end
