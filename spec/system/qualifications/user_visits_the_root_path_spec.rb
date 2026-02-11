require "rails_helper"

RSpec.feature "The root path", type: :system do
  include CommonSteps

  scenario "User visits the root path and is directed to signin" do
    given_the_qualifications_service_is_open

    when_i_visit_the_qualifications_service
    then_i_see_the_signin_with_identity_page
  end

  def then_i_see_the_signin_with_identity_page
    expect(page).to have_selector("input[type=submit][value='#{signin_button_text}']")
  end

  def signin_button_text
    "Sign in with DfE Identity"
  end
end
