# frozen_string_literal: true
module CheckRecords
  class ErrorsController < CheckRecordsController
    skip_before_action :verify_authenticity_token
    skip_before_action :authenticate_dsi_user!
    skip_before_action :handle_expired_session!

    def not_found
      render 'not_found', status: :not_found
    end

    def unprocessable_entity
      render 'unprocessable_entity', status: :unprocessable_entity
    end

    def internal_server_error
      render 'internal_server_error', status: :internal_server_error
    end
  end
end
