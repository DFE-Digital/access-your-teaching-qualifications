# frozen_string_literal: true

class CheckRecords::OmniauthCallbacksController < ApplicationController
  protect_from_forgery except: :dfe_bypass

  def dfe
    auth = request.env["omniauth.auth"]

    unless CheckRecords::DfESignIn.bypass?
      role = DfESignInApi::GetUserAccessToService.new(
        org_id: auth.extra.raw_info.organisation.id,
        user_id: auth.uid,
      ).call

      return redirect_to check_records_not_authorised_path unless role
    end

    @dsi_user = DsiUser.create_or_update_from_dsi(auth, role)
    session[:dsi_user_id] = @dsi_user.id
    session[:id_token] = auth.credentials.id_token
    session[:dsi_user_session_expiry] = 2.hours.from_now.to_i

    redirect_to check_records_root_path
  end
  alias_method :dfe_bypass, :dfe
end
