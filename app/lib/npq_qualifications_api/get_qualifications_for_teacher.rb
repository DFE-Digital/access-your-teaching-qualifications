module NpqQualificationsApi
  class GetQualificationsForTeacher
    attr_reader :user_id

    def initialize(trn:)
      @trn = trn
    end

    def call
      client = Client.new
      response = client.get_with_cache(endpoint, 
                                       cache_key: "NpqQualificationsApi/GetQualificationsForTeacher#trn:#{@trn}")

      if response.success? && response.body.any?
        response
      else
        []
      end
    end

    private

    def endpoint
      "/api/teacher-record-service/v1/qualifications/#{@trn}"
    end
  end
end
