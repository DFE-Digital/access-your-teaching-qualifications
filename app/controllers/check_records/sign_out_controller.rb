module CheckRecords
  class SignOutController < CheckRecordsController
    skip_before_action :handle_expired_session!
    skip_before_action :enforce_terms_and_conditions_acceptance!
    before_action :reset_session

    def new
      redirect_to check_records_sign_in_path
    end
  end
end
