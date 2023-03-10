class QualificationsController < ApplicationController
  before_action :authenticate_user!

  def show
    begin
      client =
        QualificationsApi::Client.new(token: session[:identity_user_token])
      @teacher = client.teacher
    rescue QualificationsApi::InvalidTokenError
      redirect_to sign_out_path
      return
    end

    if @teacher
      @qts =
        Struct.new(:name, :status, :awarded_at).new(
          "Qualified teacher status (QTS)",
          @teacher.qts_date.present? ? :awarded : :not_awarded,
          @teacher.qts_date
        )
      @itt = @teacher.itt
    end

    @user =
      current_user ||
        User.new(
          date_of_birth: Date.new(2000, 1, 1),
          name: "Jane Smith",
          trn: "1234567"
        )
    @induction = @user.induction
  end
end
