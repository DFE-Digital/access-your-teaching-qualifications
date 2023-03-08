class Users::SignInController < ApplicationController
  before_action :redirect_to_qualifications, if: :user_signed_in?

  def new
  end

  def redirect_to_qualifications
    redirect_to qualifications_path
  end
end
