# frozen_string_literal: true

class CheckRecords::OmniauthCallbacksController < ApplicationController
  protect_from_forgery except: :dfe_bypass

  def dfe
    @dsi_user = DsiUser.create_or_update_from_dsi(request.env["omniauth.auth"])

    if @dsi_user.valid_organisation?
      session[:dsi_user_id] = @dsi_user.id
      session[:dsi_user_session_expiry] = 2.hours.from_now.to_i
    else
      flash[
        :alert
      ] = "You are not a member of an organisation that is authorised to use this service."
    end

    redirect_to check_records_root_path
  end
  alias_method :dfe_bypass, :dfe
end
