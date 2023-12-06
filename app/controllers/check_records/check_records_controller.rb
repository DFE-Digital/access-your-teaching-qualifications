module CheckRecords
  class CheckRecordsController < ApplicationController
    include DsiAuthenticatable

    layout "check_records_layout"

    helper_method :current_dsi_user

    # Differentiate web requests sent to BigQuery via dfe-analytics
    def current_namespace
      "check-the-record-of-a-teacher"
    end
  end
end
