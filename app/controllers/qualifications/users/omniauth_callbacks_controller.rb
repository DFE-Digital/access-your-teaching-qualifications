# frozen_string_literal: true

module Qualifications
  module Users
    class OmniauthCallbacksController < ApplicationController
      # Differentiate web requests sent to BigQuery via dfe-analytics
      def current_namespace
        "access-your-teaching-qualifications"
      end

      def complete
        auth = request.env["omniauth.auth"]
        current_session = CurrentSession.create_session(session, auth)
        @user = current_session.current_user

        log_auth_credentials_in_development(auth)
        redirect_to qualifications_dashboard_path
      end

      private

      def log_auth_credentials_in_development(auth)
        if Rails.env.development?
          Rails.logger.debug auth.credentials.token
          Rails.logger.debug Time.zone.at auth.credentials.expires_in
        end
      end
    end
  end
end
