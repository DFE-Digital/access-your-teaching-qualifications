# frozen_string_literal: true

module CheckRecords
  class SearchController < CheckRecordsController
    def new
      @search = Search.new
    end

    def show
      unless params["search"] &&
        params["search"].key?("date_of_birth(1i)") &&
        params["search"].key?("date_of_birth(2i)") &&
        params["search"].key?("date_of_birth(3i)")
        redirect_to check_records_search_path, notice: "Please enter a date of birth"
        return
      end
      date_of_birth = [
        params["search"]["date_of_birth(1i)"],
        params["search"]["date_of_birth(2i)"],
        params["search"]["date_of_birth(3i)"]
      ]
      @search =
        Search.new(
          date_of_birth:,
          last_name: params[:search][:last_name],
          searched_at: Time.zone.now
        )
      if @search.invalid?
        render :new
      else
        @total, @teachers =
          QualificationsApi::Client.new(
            token: ENV["QUALIFICATIONS_API_FIXED_TOKEN"]
          ).teachers(
            date_of_birth: @search.date_of_birth,
            last_name: @search.last_name
          )

        SearchLog.create!(
          dsi_user: current_dsi_user,
          last_name: @search.last_name,
          date_of_birth: @search.date_of_birth.to_s,
          result_count: @total
        )
      end
    end
  end
end
