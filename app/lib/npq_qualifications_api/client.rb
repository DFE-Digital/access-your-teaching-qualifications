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
      response = client.get(endpoint, options)
      # Raising inside get_with_cache's fetch block also keeps failed responses out of the cache
      raise NpqQualificationsApi::ApiError, "API returned status #{response.status}" unless response.success?

      response
    rescue Faraday::Error => e
      raise NpqQualificationsApi::ApiError, "API request failed: #{e.message}"
    end

    def get_with_cache(endpoint, options = {}, cache_key:, expires_in: 15.minutes)
      Rails.cache.fetch(cache_key_sha(endpoint, options, cache_key), expires_in: expires_in) do
        # The block validates the response; raising from it keeps the response out of the cache
        get(endpoint, options).tap { |response| yield response if block_given? }
      end
    end

    private

    def cache_key_sha(endpoint, options, cache_key)
      key_hash = {
        cache_key: cache_key,
        endpoint: endpoint,
        options: options,
        faraday_version: Gem.loaded_specs["faraday"].version, # if we update Faraday, cached responses may not be valid
        app_version: ENV.fetch("GIT_SHA", "local") # a deploy drops responses cached by the previous release
      }

      Digest::SHA256.hexdigest(key_hash.to_json)
    end
  end
end
