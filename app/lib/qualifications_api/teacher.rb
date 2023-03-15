module QualificationsApi
  class Teacher
    attr_reader :api_data

    def initialize(api_data)
      @api_data = api_data
    end

    def first_name
      api_data.fetch("firstName")
    end

    def itt
      teaching_training_response = api_data.dig("initialTeacherTraining", 0)
      return if teaching_training_response.nil?

      Struct.new(
        :name,
        :qualification_name,
        :provider_name,
        :programme_type,
        :subjects,
        :start_date,
        :end_date,
        :result,
        :age_range
      ).new(
        "Initial teacher training (ITT)",
        teaching_training_response.dig("qualification", "name"),
        teaching_training_response.dig("provider", "name"),
        teaching_training_response["programmeType"],
        teaching_training_response["subjects"].map do |subject|
          subject["name"]
        end,
        teaching_training_response["startDate"]&.to_date,
        teaching_training_response["endDate"]&.to_date,
        teaching_training_response["result"]&.humanize,
        teaching_training_response.dig("ageRange", "description")
      )
    end

    def last_name
      api_data.fetch("lastName")
    end

    def qts_date
      api_data.dig("qts", "awarded")&.to_date
    end

    def trn
      api_data.fetch("trn")
    end
  end
end
