# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Viewing feedback" do
  include AuthorizationSteps
  include AuthenticationSteps

  scenario "Staff user views feedback", host: :check_records, test: :with_stubbed_auth do
    when_i_am_authorized_with_basic_auth
    when_i_sign_in_as_staff_via_dsi
    and_feeback_submissions_exist
    when_i_visit_the_feedback_page
    then_i_see_the_feedback_submissions
  end

  private

  def and_feeback_submissions_exist
    create(:feedback)
    create(
      :feedback,
      contact_permission_given: false,
      satisfaction_rating: "very_dissatisfied",
      improvement_suggestion: "Do it again properly",
      created_at: 1.day.ago,
    )
  end

  def when_i_visit_the_feedback_page
    visit "/support/feedback"
  end

  def then_i_see_the_feedback_submissions
    expect(page).to have_css(".govuk-service-navigation__item--active", text: "Feedback")
    expect(page).to have_css("h1", text: "Feedback")

    h2s = page.all("h2")
    summary_lists = page.all("dl")

    within(h2s[0]) do
      expect(page).to have_content("someone-1@example.com")
    end

    within(summary_lists[0]) do
      expect(page).to have_content("I would like to see more of this")
      expect(page).to have_content("Very satisfied")
    end

    within(h2s[1]) do
      expect(page).to have_content("someone-2@example.com")
    end

    within(summary_lists[1]) do
      expect(page).to have_content("Do it again properly")
      expect(page).to have_content("Very dissatisfied")
    end
  end
end
