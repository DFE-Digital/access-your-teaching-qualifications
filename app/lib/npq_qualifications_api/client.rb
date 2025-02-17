module NPQQualificationsApi
  class InvalidCertificateUrlError < StandardError; end
  class ForbiddenError < StandardError; end
  class UnknownError < StandardError; end
  class ApiError < StandardError; end

  class Client
    TIMEOUT_IN_SECONDS = 30

    attr_reader :token

    def initialize(token:)
      @token = token
    end

    def client
      @client ||=
        Faraday.new(
          url: ENV.fetch("NPQ_QUALIFICATIONS_API_URL"),
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

    private

    def get(endpoint, options = {})
      client.get(endpoint, options)
    rescue Faraday::ConnectionFailed, Faraday::TimeoutError => e
      raise NPQQualificationsApi::ApiError, "API connection failed: #{e.message}"
    end
  end
end
