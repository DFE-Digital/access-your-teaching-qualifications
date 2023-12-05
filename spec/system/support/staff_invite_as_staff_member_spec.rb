require 'rails_helper'

RSpec.feature 'Staff support', type: :system do
  include CommonSteps

  scenario "Staff user invites another Staff member" do
    given_the_support_service_is_open
    and_a_staff_member_exists
    and_i_am_logged_in_as_a_staff_member
    when_i_visit_the_staff_page
    then_i_see_the_staff_index

    when_i_click_on_invite
    then_i_see_the_staff_invitation_form

    when_i_fill_the_invitation_form
    and_i_send_invitation
    then_i_see_an_invitation_email
    then_i_see_the_staff_index
    then_i_see_the_invited_staff_user
  end

  private

  def and_a_staff_member_exists
    create(:staff, :confirmed)
  end

  def and_i_am_logged_in_as_a_staff_member
    visit new_staff_session_path
    fill_in 'Email', with: 'staff@example.com'
    fill_in 'Password', with: 'password'
    click_button 'Log in'
  end

  def when_i_visit_the_staff_page
    visit support_interface_staff_index_path
  end

  def then_i_see_the_staff_index
    expect(page).to have_current_path('/support/staff')
    expect(page).to have_content('Staff')
  end

  def when_i_click_on_invite
    click_link 'Invite staff user'
  end

  def then_i_see_the_staff_invitation_form 
    expect(page).to have_current_path('/staff/invitation/new')
    expect(page).to have_content('Send invitation')
  end

  def when_i_fill_the_invitation_form
    fill_in 'Email', with: 'invite@example.com'
  end

  def and_i_send_invitation
    click_button 'Send an invitation'
  end

  def then_i_see_an_invitation_email
    perform_enqueued_jobs
    message = ActionMailer::Base.deliveries.first
    expect(message).to_not be_nil

    expect(message.subject).to eq("Invitation instructions")
    expect(message.to).to include("invite@example.com")
  end

  def then_i_see_the_invited_staff_user
    expect(page).to have_content("invite@example.com")
  end
end
  