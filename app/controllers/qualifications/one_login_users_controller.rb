module Qualifications
  class OneLoginUsersController < QualificationsInterfaceController
    before_action :redirect_to_root_unless_one_login_enabled

    def show
      # TODO: add error handling similar to QualificationsController
      client = QualificationsApi::Client.new(token: session[user_token_session_key])
      @teacher = client.teacher
    end
  end
end
