class QualificationsController < ApplicationController
  before_action :authenticate_user!

  def show
    @user =
      current_user ||
        User.new(
          date_of_birth: Date.new(2000, 1, 1),
          name: "Jane Smith",
          trn: "1234567"
        )
    @qts = @user.qts
    @induction = @user.induction
    @itt = @user.itt
  end
end
