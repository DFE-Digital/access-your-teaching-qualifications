module Qualifications
  module Users
    class SignInController < QualificationsInterfaceController
      skip_before_action :authenticate_user!
      skip_before_action :handle_expired_token!

      def new
      end
    end
  end
end
