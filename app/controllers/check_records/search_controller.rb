# frozen_string_literal: true

module CheckRecords
  class SearchController < CheckRecordsController
    before_action :redirect_to_root_unless_trn_search_enabled, only: [:trn_search, :trn_result]

    def personal_details_search
      @search = Search.new
      @organisation_name = current_dsi_user.dsi_user_sessions.last&.organisation_name
    end

    def personal_details_result
      unless all_date_params_present?
        redirect_to(check_records_search_path, notice: "Please enter a date of birth") and return
      end

      @search = build_personal_details_search
      if @search.invalid?
        render :personal_details_search
      else
        @total, @teachers = search_qualifications_api_with_personal_details(@search)
        log_search(:personal_details, @search.last_name, @search.date_of_birth, @total)

        if @total > 1 && FeatureFlags::FeatureFlag.active?(:trn_search)
          redirect_to check_records_trn_search_path(search: search_params) and return
        end
      end
    end

    def trn_search
      @trn_search = TrnSearch.new
    end

    def trn_result
      @trn_search = TrnSearch.new(trn: search_params[:trn])
      render :trn_search and return if(@trn_search.invalid? && !skipped?)

      personal_details_search = build_personal_details_search
      @total, @teachers = search_qualifications_api_with_personal_details(personal_details_search)

      if skipped?
        log_search(
          :skip_trn_use_personal_details,
          personal_details_search.last_name,
          personal_details_search.date_of_birth,
          @total
        )
        return
      end

      @teacher = @trn_search.find_teacher(teachers: @teachers)
      if @teacher
        log_search(:trn, personal_details_search.last_name, personal_details_search.date_of_birth, 1)
      else
        log_search(:trn, personal_details_search.last_name, personal_details_search.date_of_birth, 0)
        @search = personal_details_search
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
        last_name: params[:search][:last_name]
      )
    end

    def search_qualifications_api_with_personal_details(search)
      qualifications_api_client.teachers(
        date_of_birth: search.date_of_birth,
        last_name: search.last_name
      )
    end

    def search_qualifications_api_with_trn(trn)
      qualifications_api_client.teacher(trn:)
    end

    def qualifications_api_client
      QualificationsApi::Client.new(
        token: ENV["QUALIFICATIONS_API_FIXED_TOKEN"]
      )
    end

    # To make passing of params easier within the search flow, we use the same
    # params method in both personal details and TRN-based searches. This is
    # achieved by using the `scope` option in the @trn_search form, so that its
    # submitted parameters sit under a :search top-level key (as opposed to
    # :trn_search).
    def search_params
      params.require(:search).permit(:last_name, :date_of_birth, :trn)
    end
    helper_method :search_params

    def skipped?
      params[:skipped] == 't'
    end
    helper_method :skipped?

    def redirect_to_root_unless_trn_search_enabled
      unless FeatureFlags::FeatureFlag.active?(:trn_search)
        redirect_to check_records_root_path
      end
    end

    def log_search(type, last_name, date_of_birth, total)
      SearchLog.create!(
        dsi_user: current_dsi_user,
        last_name:,
        date_of_birth: date_of_birth.to_s,
        result_count: total,
        search_type: type,
      )
    end
  end
end
