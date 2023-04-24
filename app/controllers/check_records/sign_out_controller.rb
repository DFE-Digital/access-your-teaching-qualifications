module CheckRecords
  class SignOutController < CheckRecordsController
    def new
      session[:dsi_user_id] = nil if dsi_user_signed_in?
    end
  end
end
