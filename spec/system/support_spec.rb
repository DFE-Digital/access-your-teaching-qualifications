# frozen_string_literal: true
require "rails_helper"

RSpec.feature "Support", type: :system do
  scenario "visiting the support interface" do
    when_i_am_authorized_as_a_support_user
    and_i_visit_the_support_page
    then_i_see_the_support_page
  end

  private

  def when_i_am_authorized_as_a_support_user
    page.driver.basic_authorize("test", "test")
  end

  def and_i_visit_the_support_page
    visit support_interface_path
  end

  def then_i_see_the_support_page
    expect(page).to have_current_path(support_interface_path)
  end
end
