module NpqQualificationsApi
  class GetQualificationsForTeacher
    attr_reader :user_id

    def initialize(trn:)
      @trn = trn
    end

    def call
      Client.new.get_with_cache(endpoint,
                                cache_key: "NpqQualificationsApi/GetQualificationsForTeacher#trn:#{@trn}") do |response|
        validate_body!(response.body)
        report_unrecognised_npq_types(response.body)
      end
    end

    private

    def validate_body!(body)
      raise ApiError, "NPQ API response is missing data.qualifications" unless qualifications_list?(body)

      body["data"]["qualifications"].each { |qualification| validate_qualification!(qualification) }
    end

    def validate_qualification!(qualification)
      raise ApiError, "NPQ qualification is missing npq_type" unless npq_type?(qualification)
      return if undated?(qualification["award_date"]) # an undated NPQ still renders, without its date
      return if iso8601_date?(qualification["award_date"])

      raise ApiError, "NPQ qualification has an invalid award_date: #{qualification["award_date"].inspect}"
    end

    # Unrecognised types still render under a fallback name, so they're reported rather than rejected
    def report_unrecognised_npq_types(body)
      body["data"]["qualifications"].each do |qualification|
        type = qualification["npq_type"]
        next if QualificationsApi::Teacher::NPQ_QUALIFICATION_NAME.key?(type.to_sym)

        Sentry.capture_message("Unrecognised NPQ type #{type.inspect} from the NPQ API")
      end
    end

    def qualifications_list?(body)
      body.is_a?(Hash) && body["data"].is_a?(Hash) && body["data"]["qualifications"].is_a?(Array)
    end

    def npq_type?(qualification)
      qualification.is_a?(Hash) && qualification["npq_type"].is_a?(String) && qualification["npq_type"].present?
    end

    def undated?(value)
      value.nil? || (value.is_a?(String) && value.blank?)
    end

    def iso8601_date?(value)
      value.is_a?(String) && Date.iso8601(value)
    rescue ArgumentError # Date::Error's parent; iso8601 raises it directly for strings over 128 characters
      false
    end

    def endpoint
      "/api/teacher-record-service/v1/qualifications/#{@trn}"
    end
  end
end
