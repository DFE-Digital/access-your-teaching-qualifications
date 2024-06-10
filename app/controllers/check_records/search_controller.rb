# frozen_string_literal: true

module CheckRecords
  class SearchController < CheckRecordsController
    def new
      @search = Search.new
    end

    def show
      unless all_date_params_present?
        redirect_to(check_records_search_path, notice: "Please enter a date of birth") and return
      end

      @search = build_personal_details_search
      if @search.invalid?
        render :new
      else
        @total, @teachers = search_qualifications_api_with_personal_details(@search)
        SearchLog.create!(
          dsi_user: current_dsi_user,
          last_name: @search.last_name,
          date_of_birth: @search.date_of_birth.to_s,
          result_count: @total
        )
      end
    end

    private

    def all_date_params_present?
      return false if params["search"].blank?

      %w[date_of_birth(1i) date_of_birth(2i) date_of_birth(3i)].all? do |key|
        params[:search].key?(key)
      end
    end

    def date_of_birth_params_to_array
      [
        params[:search]["date_of_birth(1i)"],
        params[:search]["date_of_birth(2i)"],
        params[:search]["date_of_birth(3i)"]
      ]
    end

    def build_personal_details_search
      Search.new(
        date_of_birth: date_of_birth_params_to_array,
        last_name: params[:search][:last_name],
        searched_at: Time.zone.now
      )
    end

    def search_qualifications_api_with_personal_details(search)
      QualificationsApi::Client.new(
        token: ENV["QUALIFICATIONS_API_FIXED_TOKEN"]
      ).teachers(
        date_of_birth: search.date_of_birth,
        last_name: search.last_name
      )
    end

    def search_params
      params.require(:search).permit(:last_name, :date_of_birth)
    end
  end
end
