module CheckRecords
  class CheckRecordsController < ApplicationController
    include DsiAuthenticatable

    before_action :enforce_terms_and_conditions_acceptance!

    http_basic_authenticate_with(
      name: ENV.fetch("SUPPORT_USERNAME", nil),
      password: ENV.fetch("SUPPORT_PASSWORD", nil),
      unless: -> { FeatureFlags::FeatureFlag.active?("check_service_open") }
    )

    layout "check_records_layout"

    helper_method :current_dsi_user

    # Differentiate web requests sent to BigQuery via dfe-analytics
    def current_namespace
      "check-a-teachers-record"
    end

    def enforce_terms_and_conditions_acceptance!
      if current_dsi_user&.acceptance_required?
        redirect_to check_records_terms_and_conditions_path
      end
    end
  end
end
