# frozen_string_literal: true

module CheckRecords
  class TermsAndConditionsController < CheckRecordsController
    def show
    end

    def update
      current_dsi_user.update!(
        terms_and_conditions_version_accepted: CURRENT_TERMS_AND_CONDITIONS_VERSION,
        terms_and_conditions_timestamp: Time.zone.now
      )
      redirect_to check_records_root_path, notice: "Terms and conditions accepted"
    end
  end
end
