# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # More info at:
  # https://github.com/heartcombo/devise#omniauth

  def identity
    auth = request.env["omniauth.auth"]
    @user = User.from_identity(auth)
    sign_in @user
    session[:identity_user_token] = auth.credentials.token
    session[:identity_user_token_expiry] = auth.credentials.expires_at
    log_auth_credentials_in_development(auth)
    flash[:notice] = "Signed in successfully."
    redirect_to root_path
  end

  # def passthru
  #   super
  # end

  def failure
    flash[:warning] = "There was a problem. Please try signing in again"
    super
  end

  protected

  # The path used when OmniAuth fails
  def after_omniauth_failure_path_for(_scope)
    sign_in_path
  end

  private

  def log_auth_credentials_in_development(auth)
    if Rails.env.development?
      Rails.logger.debug auth.credentials.token
      Rails.logger.debug Time.zone.at auth.credentials.expires_at
    end
  end
end
