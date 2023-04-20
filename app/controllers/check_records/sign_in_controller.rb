module CheckRecords
  class SignInController < CheckRecordsController
    skip_before_action :authenticate_dsi_user!

    def new
    end
  end
end
