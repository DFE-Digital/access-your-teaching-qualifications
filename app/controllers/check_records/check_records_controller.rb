module CheckRecords
  class CheckRecordsController < ApplicationController
    before_action :authenticate_dsi_user!

    layout "check_records_layout"

    def current_dsi_user
      @current_dsi_user ||= DsiUser.find(session[:dsi_user_id]) if session[:dsi_user_id]
    end
    helper_method :current_dsi_user

    def authenticate_dsi_user!
      if current_dsi_user.blank?
        flash[:warning] = "You need to sign in to continue."
        redirect_to check_records_sign_in_path
      end
    end

    def dsi_user_signed_in?
      !!current_dsi_user
    end
  end
end
