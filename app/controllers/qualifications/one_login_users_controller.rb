module Qualifications
  class OneLoginUsersController < QualificationsInterfaceController
    before_action :redirect_to_root_unless_one_login_enabled

    def show
      # TODO: add error handling similar to QualificationsController
      client = QualificationsApi::Client.new(token: session[user_token_session_key])
      @teacher = client.teacher
    end

    private

    def redirect_to_root_unless_one_login_enabled
      unless FeatureFlags::FeatureFlag.active?(:one_login)
        redirect_to qualifications_root_path
      end
    end
  end
end
