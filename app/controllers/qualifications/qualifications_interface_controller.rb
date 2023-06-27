module Qualifications
  class QualificationsInterfaceController < ApplicationController
    before_action :authenticate_user!
    before_action :handle_expired_token!

    layout "qualifications_layout"

    def current_user
      @current_user ||= User.find(session[:identity_user_id]) if session[:identity_user_id]
    end
    helper_method :current_user

    def authenticate_user!
      if current_user.blank?
        flash[:warning] = "You need to sign in to continue."
        redirect_to qualifications_root_path
      end
    end

    def user_signed_in?
      !!current_user
    end

    def handle_expired_token!
      redirect_to qualifications_sign_out_path unless session[:identity_user_token_expiry]

      if Time.zone.at(session[:identity_user_token_expiry]).past?
        flash[:warning] = "Your session has expired. Please sign in again."
        redirect_to qualifications_sign_out_path
      end
    end
  end
end
