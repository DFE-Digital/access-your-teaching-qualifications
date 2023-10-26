# frozen_string_literal: true
module CheckRecords
  class ErrorsController < CheckRecordsController
    include HttpErrorHandling

    skip_before_action :authenticate_dsi_user!
    skip_before_action :handle_expired_session!
  end
end
