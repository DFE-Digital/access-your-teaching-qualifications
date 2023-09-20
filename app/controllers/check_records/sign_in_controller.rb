module CheckRecords
  class SignInController < CheckRecordsController
    skip_before_action :authenticate_dsi_user!
    skip_before_action :handle_expired_session!

    def new
    end

    def not_authorised
    end
  end
end
