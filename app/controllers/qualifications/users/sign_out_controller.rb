module Qualifications
  module Users
    class SignOutController < QualificationsInterfaceController
      skip_before_action :handle_expired_token!

      def new
        if user_signed_in?
          session[:identity_user_id] = nil
          session[:identity_user_token] = nil
          redirect_to "/qualifications/users/auth/identity/logout"
        else
          redirect_to qualifications_start_path
        end
      end
    end
  end
end
