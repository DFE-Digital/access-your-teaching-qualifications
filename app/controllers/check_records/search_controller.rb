# frozen_string_literal: true

module CheckRecords
  class SearchController < CheckRecordsController
    def new
    end

    def show
      redirect_to check_records_search_path if params[:trn].blank?

      client = QualificationsApi::Client.new(token: ENV["QUALIFICATIONS_API_FIXED_TOKEN"])
      @teacher = client.teacher(trn: params[:trn])
    end
  end
end
