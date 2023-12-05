module CheckRecords
  class CheckRecordsController < ApplicationController
    before_action :authenticate_dsi_user!
    before_action :handle_expired_session!

    http_basic_authenticate_with(
      name: ENV.fetch("SUPPORT_USERNAME", nil),
      password: ENV.fetch("SUPPORT_PASSWORD", nil),
      unless: -> { FeatureFlags::FeatureFlag.active?("check_service_open") }
    )

    layout "check_records_layout"

    def current_dsi_user
      @current_dsi_user ||= DsiUser.find(session[:dsi_user_id]) if session[:dsi_user_id]
    end
    helper_method :current_dsi_user

    # Differentiate web requests sent to BigQuery via dfe-analytics
    def current_namespace
      "check-the-record-of-a-teacher"
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
end
