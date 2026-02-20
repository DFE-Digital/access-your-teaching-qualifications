module Qualifications
  module Users
    class SignOutController < QualificationsInterfaceController
      skip_before_action :handle_expired_token!
      skip_before_action :authenticate_user!, only: :complete

      rescue_from ActionController::InvalidAuthenticityToken do
        redirect_to qualifications_start_path
      end

      def new
      end

      def create
        if user_signed_in?
          # Saving before resetting the session as this relies on session data
          omniauth_logout_path = current_session.logout_path

          reset_session

          redirect_to omniauth_logout_path
        else
          redirect_to qualifications_start_path
        end
      end

      def complete
        redirect_to qualifications_root_path
      end
    end
  end
end
