module Qualifications
  class OneLoginUsersController < QualificationsInterfaceController
    before_action :redirct_to_root_unless_one_login_enabled

    def show
    end

    private

    def redirct_to_root_unless_one_login_enabled
      unless FeatureFlag::Features.active?(:one_login)
        redirect_to qualifications_root_path
      end
    end
  end
end
