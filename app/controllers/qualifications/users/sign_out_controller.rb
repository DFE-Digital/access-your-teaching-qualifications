module Qualifications
  module Users
    class SignOutController < QualificationsInterfaceController
      skip_before_action :handle_expired_token!

      def new
        session[:identity_user_id] = nil if user_signed_in?
      end
    end
  end
end
