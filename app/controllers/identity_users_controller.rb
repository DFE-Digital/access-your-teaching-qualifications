class IdentityUsersController < QualificationsInterfaceController
  before_action :authenticate_user!

  def show
  end
end
