class QualificationsController < ApplicationController
  before_action :authenticate_user!

  def show
    client = QualificationsApi::Client.new(token: session[:identity_user_token])
    teacher = client.teacher

    if teacher
      @qts =
        Struct.new(:name, :status, :awarded_at).new(
          "Qualified teacher status (QTS)",
          teacher.qts_date.present? ? :awarded : :not_awarded,
          teacher.qts_date
        )
    end

    @user =
      current_user ||
        User.new(
          date_of_birth: Date.new(2000, 1, 1),
          name: "Jane Smith",
          trn: "1234567"
        )
    @induction = @user.induction
    @itt = @user.itt
  end
end
