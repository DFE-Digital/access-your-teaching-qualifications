module CheckRecords
  class SignOutController < CheckRecordsController
    skip_before_action :handle_expired_session!
    before_action :reset_session

    def new
      session[:dsi_user_id] = nil if dsi_user_signed_in?
      redirect_to check_records_sign_in_path
    end
  end
end
