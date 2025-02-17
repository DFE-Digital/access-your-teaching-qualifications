module NPQQualificationsApi
  class GetQualificationsForTeacher
    include Client

    attr_reader :user_id

    def initialize(trn:)
      @trn = trn
    end

    def call
      response = client.get(endpoint)

      if response.success? && response.body.any?
        response
      else
        []
      end
    end

    private

    def qualifications(response)
      response
        .sort_by { |npq| npq.award_date&.to_date }
        .reverse
        .each do |npq|
        @qualifications << Qualification.new(
          awarded_at: npq.award_date&.to_date,
          certificate_url: "present",
          name: npq.npq_type,
          type: npq.npq_type&.to_sym
        )
    end

    def endpoint
      "/api/teacher-record-service/v1/qualifications/#{@trn}"
    end
  end
end