module CheckRecords
  class SignInController < CheckRecordsController
    skip_before_action :authenticate_dsi_user!
    skip_before_action :handle_expired_session!
    before_action :reset_session, except: :not_authorised
    before_action :handle_failed_sign_in, only: :new, if: -> { params[:oauth_failure] == "true" }

    def new
    end

    def not_authorised
    end

    private

    def handle_failed_sign_in
      flash.now[:warning] = I18n.t("validation_errors.generic_oauth_failure")
    end
  end
end
