module DsiAuthenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_dsi_user!
    before_action :handle_expired_session!
  end

  def current_dsi_user
    @current_dsi_user ||= DsiUser.find(session[:dsi_user_id]) if session[:dsi_user_id]
  end

  def authenticate_dsi_user!
    if current_dsi_user.blank?
      flash[:warning] = failed_sign_in_message
      session[:return_to] = request.fullpath
      redirect_to check_records_sign_in_path
    end
  end

  def dsi_user_signed_in?
    !!current_dsi_user
  end

  def handle_expired_session!
    return unless Time.zone.at(session.fetch(:dsi_user_session_expiry, 1.minute.ago)).past?

    flash[:warning] = I18n.t("validation_errors.session_expired")
    redirect_to check_records_sign_out_path
  end

  def failed_sign_in_message
    I18n.t("validation_errors.generic_sign_in_failure")
  end
end

