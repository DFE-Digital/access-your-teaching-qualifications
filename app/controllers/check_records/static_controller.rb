# frozen_string_literal: true

module CheckRecords
  class StaticController < CheckRecordsController
    skip_before_action :authenticate_dsi_user!
    skip_before_action :handle_expired_session!
  end
end
