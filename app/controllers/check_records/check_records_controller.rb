module CheckRecords
  class CheckRecordsController < ApplicationController
    include DsiAuthenticatable

    http_basic_authenticate_with(
      name: ENV.fetch("SUPPORT_USERNAME", nil),
      password: ENV.fetch("SUPPORT_PASSWORD", nil),
      unless: -> { FeatureFlags::FeatureFlag.active?("check_service_open") }
    )

    layout "check_records_layout"

    helper_method :current_dsi_user

    # Differentiate web requests sent to BigQuery via dfe-analytics
    def current_namespace
      "check-the-record-of-a-teacher"
    end
  end
end
