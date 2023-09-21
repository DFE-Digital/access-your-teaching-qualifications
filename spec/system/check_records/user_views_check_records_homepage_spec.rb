# frozen_string_literal: true
require "rails_helper"

RSpec.feature "Check records homepage", host: :check_records do
  include CommonSteps

  scenario "User views Check records homepage" do
    given_the_service_is_open
    when_i_visit_the_check_records_homepage
    then_i_see_the_check_records_nav
    and_event_tracking_is_working
  end

  private

  def when_i_visit_the_check_records_homepage
    visit check_records_root_path
  end

  def then_i_see_the_check_records_nav
    within("header") { expect(page).to have_content("Check a teacher’s record") }
  end
end
