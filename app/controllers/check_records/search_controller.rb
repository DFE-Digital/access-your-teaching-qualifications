# frozen_string_literal: true

module CheckRecords
  class SearchController < CheckRecordsController
    def new
    end

    def show
      redirect_to check_records_search_path if params[:trn].blank?

      begin
        client = QualificationsApi::Client.new(token: ENV["QUALIFICATIONS_API_FIXED_TOKEN"])
        @teacher = client.teacher(trn: params[:trn])
      rescue QualificationsApi::TeacherNotFoundError
        render "not_found"
      end
    end
  end
end
