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
          id_token = session[:onelogin_id_token]

          reset_session

          if FeatureFlags::FeatureFlag.active?(:one_login)
            redirect_to("/qualifications/users/auth/onelogin/logout?id_token_hint=#{id_token}")
          else
            redirect_to "/qualifications/users/auth/identity/logout"
          end
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
