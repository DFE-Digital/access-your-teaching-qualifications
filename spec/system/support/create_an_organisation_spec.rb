require 'rails_helper'

RSpec.describe 'Creating an organisation', type: :system do
  include CommonSteps

  it "creates an organisation" do
    given_the_service_is_open
    and_staff_http_basic_is_active

    when_i_am_authorized_with_basic_auth
    and_i_am_on_the_organisations_page
    when_i_click_on_create_new_organisation
    and_i_fill_in_the_form
    and_i_click_on_create_organisation
    then_i_see_the_new_organisation
  end

  private

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_i_am_on_the_organisations_page
    visit support_interface_organisations_path
  end

  def when_i_click_on_create_new_organisation
    click_link 'Create new organisation'
  end

  def and_i_fill_in_the_form
    fill_in 'Company registration number', with: '12345678'
  end

  def and_i_click_on_create_organisation
    click_button 'Create organisation'
  end

  def then_i_see_the_new_organisation
    expect(page).to have_content('Organisation created')
    expect(page).to have_content('12345678')
  end
end