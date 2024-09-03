module CheckRecords
  class BulkSearchesController < CheckRecordsController
    def new
      @bulk_search = BulkSearch.new
      @organisation_name = current_dsi_user.dsi_user_sessions.last&.organisation_name
    end

    def create
      @bulk_search = BulkSearch.new(file: bulk_search_params[:file])
      @total, @results, @not_found = @bulk_search.call
      if @results
        BulkSearchLog.create!(
          csv: @bulk_search.csv,
          dsi_user_id: current_dsi_user.id,
          query_count: @bulk_search.csv.count,
          result_count: @total
        )
      else
        send_error_analytics_event
        render :new
      end

    end

    private

    def bulk_search_params
      params.require(:bulk_search).permit(:file)
    end

    def send_error_analytics_event
      event = DfE::Analytics::Event.new
        .with_type(:bulk_search_validation_error)
        .with_user(current_dsi_user)
        .with_request_details(request)
        .with_namespace(current_namespace)
        .with_data(errors: @bulk_search.errors.to_hash)

      DfE::Analytics::SendEvents.do([event])
    end
  end
end