module Qualifications
  class OneLoginUsersController < QualificationsInterfaceController
    before_action :redirect_to_root_unless_one_login_active

    def show
      # TODO: add error handling similar to QualificationsController
      client = QualificationsApi::Client.new(token: current_session.user_token)
      @teacher = client.teacher
    end
  end
end
