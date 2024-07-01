module DsiAuthenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_dsi_user!
    before_action :handle_expired_session!
  end

  CURRENT_TERMS_AND_CONDITIONS_VERSION = "1.0".freeze

  def current_dsi_user
    @current_dsi_user ||= DsiUser.find(session[:dsi_user_id]) if session[:dsi_user_id]
  end

  def authenticate_dsi_user!
    if current_dsi_user.blank?
      redirect_to check_records_sign_in_path
    end
  end

  def dsi_user_signed_in?
    !!current_dsi_user
  end

  def handle_expired_session!
    if session[:dsi_user_session_expiry].nil?
      redirect_to check_records_sign_out_path
      return
    end

    if Time.zone.at(session[:dsi_user_session_expiry]).past?
      redirect_to check_records_sign_out_path
    end
  end
end

