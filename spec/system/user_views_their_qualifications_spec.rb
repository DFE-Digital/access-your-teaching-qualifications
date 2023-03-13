require "rails_helper"

RSpec.feature "User views their qualifications", type: :system do
  include CommonSteps
  include AuthenticationSteps

  scenario "when they have qualifications", test: :with_stubbed_auth do
    given_the_service_is_open
    and_i_am_signed_in_via_identity

    when_i_visit_the_qualifications_page
    then_i_see_my_induction_details
    then_i_see_my_qts_details
    and_my_qts_certificate_is_downloadable
    then_i_see_my_itt_details
  end

  private

  def when_i_visit_the_qualifications_page
    visit qualifications_path
  end

  def then_i_see_my_induction_details
    expect(page).to have_content("Induction")
    expect(page).to have_content("Pass")
    expect(page).to have_content("1 November 2015")
  end

  def then_i_see_my_qts_details
    expect(page).to have_content("Qualified teacher status (QTS)")
    expect(page).to have_content("Awarded")
    expect(page).to have_content("27 February 2023")
    expect(page).to have_content("Download QTS certificate")
  end

  def and_my_qts_certificate_is_downloadable
    click_on "Download QTS certificate"
    expect(page.response_headers["Content-Type"]).to eq("application/pdf")
    expect(page.response_headers["Content-Disposition"]).to eq("attachment")
  end

  def then_i_see_my_itt_details
    expect(page).to have_content("Initial teacher training (ITT)")
    expect(page).to have_content("BA")
    expect(page).to have_content("Earl Spencer Primary School")
    expect(page).to have_content("HEI")
    expect(page).to have_content("Business Studies")
    expect(page).to have_content("28 February 2022")
    expect(page).to have_content("28 January 2023")
    expect(page).to have_content("Pass")
    expect(page).to have_content("10 to 16 years")
  end
end
