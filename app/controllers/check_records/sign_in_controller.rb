module CheckRecords
  class SignInController < CheckRecordsController
    skip_before_action :authenticate_dsi_user!
    skip_before_action :handle_expired_session!
    skip_before_action :enforce_terms_and_conditions_acceptance!
    before_action :handle_failed_sign_in, only: :new, if: -> { params[:oauth_failure] == "true" }

    def new
      if DfESignIn.bypass?
        redirect_post "/check-records/auth/developer", options: { authenticity_token: :auto }
      else
        redirect_post "/check-records/auth/dfe", options: { authenticity_token: :auto }
      end
    end

    def not_authorised
    end

    private

    def handle_failed_sign_in
      flash.now[:warning] = I18n.t("validation_errors.generic_oauth_failure")
    end
  end
end
