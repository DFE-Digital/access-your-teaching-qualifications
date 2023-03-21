class QualificationsController < QualificationsInterfaceController
  def show
    begin
      client = QualificationsApi::Client.new(token: session[:identity_user_token])
      @teacher = client.teacher
    rescue QualificationsApi::InvalidTokenError
      redirect_to sign_out_path
      return
    end

    @user = current_user
    @induction = @user.induction
  end
end
