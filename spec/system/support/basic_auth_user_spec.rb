# frozen_string_literal: true
require "rails_helper"

RSpec.feature "Basic auth user" do
  include CommonSteps

  scenario "Access is restricted by basic auth", type: :system do
    given_the_service_is_open
    and_staff_http_basic_is_active

    when_i_visit_the_support_interface
    then_i_am_unauthorized

    when_i_am_authorized_with_basic_auth
    when_i_refresh_and_try_again
    then_i_see_the_support_interface
  end

  private

  def when_i_refresh_and_try_again
    page.driver.refresh
  end

  def then_i_see_the_support_interface
    expect(page).to have_content("Support")
  end
end
