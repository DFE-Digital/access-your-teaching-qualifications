class Users::SignOutController < ApplicationController
  def new
    sign_out(:user) if user_signed_in?
  end
end
