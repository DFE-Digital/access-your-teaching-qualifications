# frozen_string_literal: true

class SupportInterface::OmniauthCallbacksController < ApplicationController
  protect_from_forgery except: :staff_bypass
  before_action :add_auth_attributes_to_session, only: :staff

  attr_reader :role

  def staff
    unless DfESignIn.bypass?
      check_staff_access_to_service

      return redirect_to support_interface_not_authorised_path unless role
    end

    create_or_update_dsi_user

    redirect_to support_interface_root_path
  end
  alias_method :staff_bypass, :staff

  private

  def auth
    DfESignIn.bypass? ? bypass_auth : request.env["omniauth.auth"]
  end

  def add_auth_attributes_to_session
    session[:id_token] = auth.credentials.id_token
    session[:organisation_name] = auth.extra.raw_info.organisation.name
  end

  def check_staff_access_to_service
    @role = DfESignInApi::GetStaffAccessToService.new(
      org_id: auth.extra.raw_info.organisation.id,
      user_id: auth.uid,
    ).call
  end

  def create_or_update_dsi_user
    @dsi_user = DsiUser.create_or_update_from_dsi(auth, staff: true, role:)
    session[:dsi_user_id] = @dsi_user.id
    session[:dsi_user_session_expiry] = 2.hours.from_now.to_i
  end

  def bypass_auth
    OmniAuth::AuthHash.new(
      uid: "bypass-user-uid",
      info: {
        email: "bypass@example.com",
        first_name: "Bypass",
        last_name: "User",
      },
    )
  end
end
