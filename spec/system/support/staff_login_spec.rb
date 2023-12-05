require "rails_helper"

RSpec.feature "Staff login" do
  include CommonSteps

  scenario "Staff user logs in" do
    given_the_service_is_open
    and_a_staff_user_exists
    when_i_visit_the_support_interface
    then_i_see_the_staff_login_page

    when_i_enter_my_credentials
    and_i_click_on_the_login_button
    then_i_see_the_support_interface
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
end
