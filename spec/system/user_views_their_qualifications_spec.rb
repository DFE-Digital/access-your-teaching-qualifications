require "rails_helper"

RSpec.feature "User views their qualifications", type: :system do
  include CommonSteps

  scenario "when they have qualifications" do
    given_the_service_is_open
    and_i_am_signed_in

    when_i_visit_the_qualifications_page
    then_i_see_my_induction_details
    then_i_see_my_qts_details
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
    expect(page).to have_content("1 September 2014")
  end

  def then_i_see_my_itt_details
    expect(page).to have_content("Initial teacher training (ITT)")
    expect(page).to have_content("Postgraduate Certificate in Education (PGCE)")
    expect(page).to have_content("West London University")
    expect(page).to have_content("HEI")
    expect(page).to have_content("English, Maths")
    expect(page).to have_content("1 October 2015")
    expect(page).to have_content("23 June 2018")
    expect(page).to have_content("Pass")
    expect(page).to have_content("7 to 18 years")
  end
end
