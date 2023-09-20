# frozen_string_literal: true

module CheckRecords
  class SearchController < CheckRecordsController
    def new
      @search = Search.new
    end

    def show
      date_of_birth = [
        params["search"]["date_of_birth(1i)"],
        params["search"]["date_of_birth(2i)"],
        params["search"]["date_of_birth(3i)"]
      ]
      @search =
        Search.new(date_of_birth:, last_name: params[:search][:last_name])
      if @search.invalid?
        render :new
      else
        SearchLog.create!(
          dsi_user: current_dsi_user,
          last_name: @search.last_name,
          date_of_birth: @search.date_of_birth.to_s
        )
        @total, @teachers =
          QualificationsApi::Client.new(
            token: ENV["QUALIFICATIONS_API_FIXED_TOKEN"]
          ).teachers(
            date_of_birth: @search.date_of_birth,
            last_name: @search.last_name
          )
      end
    end
  end
end
