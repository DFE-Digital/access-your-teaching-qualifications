module NpqQualificationsApi
  class InvalidCertificateUrlError < StandardError; end
  class ForbiddenError < StandardError; end
  class UnknownError < StandardError; end
  class ApiError < StandardError; end

  class Client
    TIMEOUT_IN_SECONDS = 30

    attr_reader :token

    def initialize(token: ENV["NPQ_QUALIFICATIONS_API_FIXED_TOKEN"])
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

    def get(endpoint, options = {})
      client.get(endpoint, options)
    rescue Faraday::ConnectionFailed, Faraday::TimeoutError => e
      raise NpqQualificationsApi::ApiError, "API connection failed: #{e.message}"
    end

    def get_with_cache(endpoint, options = {}, cache_key:, expires_in: 15.minutes)
      Rails.cache.fetch(cache_key_sha(endpoint, options, cache_key), expires_in: expires_in) do
        get(endpoint, options)
      end
    end

    private

    def cache_key_sha(endpoint, options, cache_key)
      key_hash = {
        cache_key: cache_key,
        endpoint: endpoint,
        options: options,
        faraday_version: Gem.loaded_specs['faraday'].version # if we update Faraday, cached responses may not be valid
      }

      Digest::SHA256.hexdigest(key_hash.to_json)
    end
  end
end
