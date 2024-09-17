require 'pagy/extras/array'

module CheckRecords
  class BulkSearchesController < CheckRecordsController
    include Pagy::Backend

    def new
      @bulk_search = BulkSearch.new
      @organisation_name = current_dsi_user.dsi_user_sessions.last&.organisation_name
    end

    def create
      @bulk_search = BulkSearch.new(file: bulk_search_params[:file])
      @total, @results, @not_found = @bulk_search.call
      if @results
        @bulk_search_response = BulkSearchResponse.create!(
          dsi_user: current_dsi_user,
          body: { results: @results, not_found: @not_found },
          total: @total,
          expires_at: 30.minutes.from_now
        )

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

    def show
      @bulk_search_response = current_dsi_user.bulk_search_responses.find(params[:id])
      if @bulk_search_response.expires_at&.past?
        redirect_to new_check_records_bulk_search_path, alert: "Bulk search expired"
      end

      data = @bulk_search_response.body
      @total = @bulk_search_response.total
      @results ||= data.fetch("results", []).map do |teacher|
        QualificationsApi::Teacher.new(teacher['api_data'])
      end
      @not_found = data['not_found'].map {|record| Hashie::Mash.new(record) }
      @pagy, @results = pagy_array(@results, limit: 4)
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