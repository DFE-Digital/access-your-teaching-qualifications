require "rails_helper"

RSpec.feature "User views and updates their details" do
  include CommonSteps
  include AuthenticationSteps

  scenario "User updates their details", test: :with_stubbed_auth do
    given_the_service_is_open
    and_i_am_signed_in_via_identity
    when_i_visit_view_and_update_details
    then_i_see_the_landing_page
  end

  private

  def when_i_visit_view_and_update_details
    click_link "View and update details"
  end

  def then_i_see_the_landing_page
    expect(page).to have_text("DfE Identity account")
    expect(page).to have_button("Access your DfE Identity account")
  end
end
