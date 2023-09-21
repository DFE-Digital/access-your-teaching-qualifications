# frozen_string_literal: true

class Staff::PasswordsController < Devise::PasswordsController
  include SupportNamespaceable

  # GET /resource/password/new
  # def new
  #   super
  # end

  # POST /resource/password
  # def create
  #   super
  # end

  # GET /resource/password/edit?reset_password_token=abcdef
  # def edit
  #   super
  # end

  # PUT /resource/password
  # def update
  #   super
  # end

  # protected

  def after_resetting_password_path_for(_resource)
    support_interface_path
  end

  # The path used after sending reset password instructions
  # def after_sending_reset_password_instructions_path_for(resource_name)
  #   super(resource_name)
  # end

  def resource_params
    params.require(:staff).permit(:email, :password, :password_confirmation, :reset_password_token)
  end
end
