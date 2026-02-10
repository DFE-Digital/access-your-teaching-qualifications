module Qualifications
  class QualificationsInterfaceController < ApplicationController
    before_action :authenticate_user!
    before_action :handle_expired_token!
    before_action :set_active_storage_url_options

    http_basic_authenticate_with(
      name: ENV.fetch("SUPPORT_USERNAME", nil),
      password: ENV.fetch("SUPPORT_PASSWORD", nil),
      unless: -> { FeatureFlags::FeatureFlag.active?("qualifications_service_open") }
    )

    layout "qualifications_layout"

    def current_session
      @current_session ||= CurrentSession.new(session)
    end
    helper_method :current_session

    delegate :current_user, to: :current_session
    helper_method :current_user

    # Differentiate web requests sent to BigQuery via dfe-analytics
    def current_namespace
      "access-your-teaching-qualifications"
    end

    def authenticate_user!
      if current_user.blank?
        flash[:warning] = "You need to sign in to continue."
        redirect_to qualifications_root_path
      end
    end

    def user_signed_in?
      !!current_user
    end

    def handle_expired_token!
      if current_session.session_expired?
        reset_session
        flash[:warning] = "Your session has expired. Please sign in again."
        redirect_to qualifications_sign_in_path
      end
    end

    def set_active_storage_url_options
      if Rails.env.test?
        ActiveStorage::Current.url_options = { host: 'localhost', port: 3000, protocol: 'http' }
      end
    end

    def redirect_to_root_unless_one_login_active
      unless current_session.logged_in_via_one_login?
        redirect_to qualifications_root_path
      end
    end
  end
end
