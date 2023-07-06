# frozen_string_literal: true

module Qualifications
  module Users
    class OmniauthCallbacksController < ApplicationController
      def identity
        auth = request.env["omniauth.auth"]
        @user = User.from_identity(auth)
        session[:identity_user_id] = @user.id
        session[:identity_user_token] = auth.credentials.token
        session[:identity_user_token_expiry] = auth.credentials.expires_in.seconds.from_now.to_i

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
