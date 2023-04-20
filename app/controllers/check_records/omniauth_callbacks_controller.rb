# frozen_string_literal: true

class CheckRecords::OmniauthCallbacksController < ApplicationController
  protect_from_forgery except: :dfe_bypass

  def dfe_bypass
    @dsi_user = DsiUser.create_or_update_from_dsi(request.env["omniauth.auth"])
    @dsi_user.begin_session!(session)

    redirect_to check_records_root_path
  end
end
