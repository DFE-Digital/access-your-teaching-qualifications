# frozen_string_literal: true

module CheckRecords
  class TermsAndConditionsController < CheckRecordsController
    skip_before_action :enforce_terms_and_conditions_acceptance!

    def show
    end

    def update
      current_dsi_user.accept_terms!
      redirect_to check_records_root_path, notice: "Terms and conditions accepted"
    end
  end
end
