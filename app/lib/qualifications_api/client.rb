module QualificationsApi
  class Client
    TIMEOUT_IN_SECONDS = 5

    attr_reader :token

    def initialize(token:)
      @token = token
    end

    def teacher
      response = client.get("v3/teacher")

      case response.status
      when 200
        QualificationsApi::Teacher.new response.body
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
