# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # More info at:
  # https://github.com/heartcombo/devise#omniauth

  def identity
    auth = request.env["omniauth.auth"]
    @user = User.from_identity(auth)
    sign_in @user
    session[:identity_user_token] = auth.credentials.token
    flash[:notice] = "Signed in successfully."
    redirect_to root_path
  end

  # def passthru
  #   super
  # end

  # def failure
  #   super
  # end

  # protected

  # The path used when OmniAuth fails
  # def after_omniauth_failure_path_for(scope)
  #   super(scope)
  # end
end
