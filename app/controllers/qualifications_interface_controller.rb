class QualificationsInterfaceController < ApplicationController
  before_action :authenticate_user!
  before_action :handle_expired_token!

  def handle_expired_token!
    redirect_to sign_out_path unless session[:identity_user_token_expiry]

    if Time.zone.at(session[:identity_user_token_expiry]).past?
      flash[:warning] = "Your session has expired. Please sign in again."
      redirect_to sign_out_path
    end
  end
end
