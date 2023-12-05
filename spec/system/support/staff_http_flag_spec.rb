require "rails_helper"

RSpec.feature "Staff HTTP feature flag" do
  include CommonSteps

  scenario "Feature flag is disabled and no Staff accounts exist" do
    given_the_service_is_open

    when_i_visit_the_support_interface
    then_i_am_unauthorized

    when_i_am_authorized_with_basic_auth
    and_i_refresh_and_try_again
    then_i_see_the_support_interface
  end

  private

  def and_i_refresh_and_try_again
    page.driver.refresh
  end

  def then_i_see_the_support_interface
    expect(page).to have_content("Support")
  end
end
