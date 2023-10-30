# frozen_string_literal: true

class CheckRecords::OmniauthCallbacksController < ApplicationController
  protect_from_forgery except: :dfe_bypass
  before_action :add_auth_attributes_to_session, only: :dfe

  attr_reader :role

  def dfe
    unless CheckRecords::DfESignIn.bypass?
      check_user_access_to_service

      return redirect_to check_records_not_authorised_path unless role
    end

    create_or_update_dsi_user

    redirect_to check_records_root_path
  end
  alias_method :dfe_bypass, :dfe

  private

  def auth
    request.env["omniauth.auth"]
  end

  def add_auth_attributes_to_session
    session[:id_token] = auth.credentials.id_token
    session[:organisation_name] = auth.extra.raw_info.organisation.name
  end

  def check_user_access_to_service
    @role = DfESignInApi::GetUserAccessToService.new(
      org_id: auth.extra.raw_info.organisation.id,
      user_id: auth.uid,
    ).call
  end

  def create_or_update_dsi_user
    @dsi_user = DsiUser.create_or_update_from_dsi(auth, role:)
    session[:dsi_user_id] = @dsi_user.id
    session[:dsi_user_session_expiry] = 2.hours.from_now.to_i
  end
end
