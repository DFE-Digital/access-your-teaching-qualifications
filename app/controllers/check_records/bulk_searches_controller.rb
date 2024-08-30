module CheckRecords
  class BulkSearchesController < CheckRecordsController
    def new
      @bulk_search = BulkSearch.new
      @organisation_name = current_dsi_user.dsi_user_sessions.last&.organisation_name
    end

    def create
      @bulk_search = BulkSearch.new(file: bulk_search_params[:file])
      @total, @results, @not_found = @bulk_search.call
      unless @results
        render :new
      end
    end

    private

    def bulk_search_params
      params.require(:bulk_search).permit(:file)
    end
  end
end