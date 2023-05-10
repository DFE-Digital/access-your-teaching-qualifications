module QualificationsApi
  class Client
    TIMEOUT_IN_SECONDS = 5

    attr_reader :token

    def initialize(token:)
      @token = token
    end

    def certificate(type:, id: nil)
      response = client.get(["v3/certificates/#{type}", id].compact.join("/"))

      case response.status
      when 200
        response.body
      when 401
        raise QualificationsApi::InvalidTokenError
      end
    end

    def teacher(trn: nil)
      # If TRN is provided, we use an endpoint which expects a fixed Bearer token.
      # If TRN is blank, the token needs to come from an authenticated Identity user.
      endpoint = (trn ? "v3/teachers/#{trn}" : "v3/teacher")
      response =
        client.get(
          endpoint,
          {
            include: %w[
              Induction
              InitialTeacherTraining
              NpqQualifications
              MandatoryQualifications
            ].join(",")
          }
        )

      case response.status
      when 200
        QualificationsApi::Teacher.new response.body
      when 404
        raise QualificationsApi::TeacherNotFoundError
      when 401
        raise QualificationsApi::InvalidTokenError
      end
    end

    def client
      @client ||=
        Faraday.new(
          url: ENV.fetch("QUALIFICATIONS_API_URL"),
          request: {
            timeout: TIMEOUT_IN_SECONDS
          }
        ) do |faraday|
          faraday.request :authorization, "Bearer", token
          faraday.request :json
          faraday.response :json
          faraday.adapter Faraday.default_adapter
        end
    end
  end
end
