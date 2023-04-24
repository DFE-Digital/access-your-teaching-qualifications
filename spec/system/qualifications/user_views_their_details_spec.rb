require "rails_helper"

RSpec.feature "User views their details" do
  include CommonSteps
  include QualificationAuthenticationSteps

  scenario "The details are retrieved from the API", test: :with_stubbed_auth do
    given_the_service_is_open
    and_i_am_signed_in_via_identity
    then_i_see_my_details_as_returned_by_the_api
    and_event_tracking_is_working
  end

  def then_i_see_my_details_as_returned_by_the_api
    expect(page).to have_content("Terry Walsh")
    expect(page).to have_content("3000299")
  end
end
