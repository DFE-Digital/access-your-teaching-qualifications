module Qualifications
  class QualificationsInterfaceController < ApplicationController
    before_action :authenticate_user!
    before_action :handle_expired_token!

    http_basic_authenticate_with(
      name: ENV.fetch("SUPPORT_USERNAME", nil),
      password: ENV.fetch("SUPPORT_PASSWORD", nil),
      unless: -> { FeatureFlags::FeatureFlag.active?("qualifications_service_open") }
    )

    layout "qualifications_layout"

    def current_user
      @current_user ||= User.find(session[user_id_session_key]) if session[user_id_session_key]
    end
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
      token = session[user_token_expiry_session_key]
      if token.blank? || Time.zone.at(token).past?
        reset_session
        flash[:warning] = "Your session has expired. Please sign in again."
        redirect_to qualifications_sign_in_path
      end
    end

    def user_id_session_key
      if FeatureFlags::FeatureFlag.active?(:one_login)
        :onelogin_user_id
      else
        :identity_user_id
      end
    end

    def user_token_session_key
      if FeatureFlags::FeatureFlag.active?(:one_login)
        :onelogin_user_token
      else
        :identity_user_token
      end
    end

    def user_token_expiry_session_key
      if FeatureFlags::FeatureFlag.active?(:one_login)
        :onelogin_user_token_expiry
      else
        :identity_user_token_expiry
      end
    end
  end
end
