module SupportInterface
  class SignOutController < SupportInterfaceController
    skip_before_action :handle_expired_session!
    before_action :reset_session

    def new
      redirect_to support_interface_sign_in_path
    end
  end
end
