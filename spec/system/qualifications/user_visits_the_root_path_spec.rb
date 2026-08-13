require "rails_helper"

RSpec.feature "The root path", type: :system do
  include CommonSteps

  scenario "User visits the root path and is directed to signin" do
    given_the_qualifications_service_is_open

    when_i_visit_the_qualifications_service
    then_i_see_the_signin_with_onelogin_page
    and_i_cannot_sign_in_with_dfe_identity
  end

  def then_i_see_the_signin_with_onelogin_page
    expect(page).to have_button("Sign in with GOV.UK One Login")
  end

  def and_i_cannot_sign_in_with_dfe_identity
    expect(page).to have_content(
      "DfE Identity account is now no longer available - if you previously used this, " \
        "sign in with GOV.UK One Login instead"
    )
    expect(page).not_to have_button("sign in with your DfE Identity account")
  end
end
