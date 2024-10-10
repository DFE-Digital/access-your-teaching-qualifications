module CheckRecords
  class SignOutController < CheckRecordsController
    skip_before_action :handle_expired_session!
    skip_before_action :enforce_terms_and_conditions_acceptance!

    def new
      session.delete(:dsi_user_id)
      redirect_to ENV.fetch("CHECK_RECORDS_GUIDANCE_URL", "https://www.gov.uk/guidance/check-a-teachers-record"),
                  allow_other_host: true
    end
  end
end
