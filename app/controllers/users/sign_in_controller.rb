class Users::SignInController < QualificationsInterfaceController
  skip_before_action :authenticate_user!
  skip_before_action :handle_expired_token!
  before_action :redirect_to_qualifications, if: :user_signed_in?

  def new
  end

  private

  def redirect_to_qualifications
    redirect_to qualifications_path
  end
end
