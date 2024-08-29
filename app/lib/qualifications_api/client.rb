module QualificationsApi
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

    def send_name_change(name_change:)
      client.headers["X-Api-Version"] = "20240416"
      endpoint = "v3/teacher/name-changes"

      body = {
        email: name_change.user.email,
        firstName: name_change.first_name,
        middleName: name_change.middle_name,
        lastName: name_change.last_name,
        evidenceFileName: name_change.evidence_filename,
        evidenceFileUrl: name_change.expiring_evidence_url,
      }.to_json

      response = client.post(endpoint) do |req|
        req.body = body
      end

      # TODO: the client has no API version set by default. Consider setting
      # a default version for all requests handled by this client, updating the
      # FakeQualificationsApi and any tests if required.
      client.headers["X-Api-Version"] = nil

      response.body.fetch "caseNumber"
    end

    def send_date_of_birth_change(date_of_birth_change:)
      client.headers["X-Api-Version"] = "20240416"
      endpoint = "v3/teacher/date-of-birth-changes"

      body = {
        email: date_of_birth_change.user.email,
        dateOfBirth: date_of_birth_change.date_of_birth.to_s,
        evidenceFileName: date_of_birth_change.evidence_filename,
        evidenceFileUrl: date_of_birth_change.expiring_evidence_url,
      }.to_json

      response = client.post(endpoint) do |req|
        req.body = body
      end

      # TODO: the client has no API version set by default. Consider setting
      # a default version for all requests handled by this client, updating the
      # FakeQualificationsApi and any tests if required.
      client.headers["X-Api-Version"] = nil

      response.body.fetch "caseNumber"
    end

    def certificate(name:, type:, url:)
      unless valid_certificate_path?(url)
        raise QualificationsApi::InvalidCertificateUrlError
      end

      response = get(url)

      case response.status
      when 200
        QualificationsApi::Certificate.new(
          file_data: response.body,
          name:,
          type:
        )
      when 401
        raise QualificationsApi::InvalidTokenError
      end
    end

    def teacher(trn: nil)
      # If TRN is provided, we use an endpoint which expects a fixed Bearer token.
      # If TRN is blank, the token needs to come from an authenticated Identity user.
      endpoint = (trn ? "v3/teachers/#{trn}" : "v3/teacher")
      response =
        get(
          endpoint,
          {
            include: %w[
              Induction
              InitialTeacherTraining
              NpqQualifications
              MandatoryQualifications
              Sanctions
              PreviousNames
              PendingDetailChanges
            ].join(",")
          }
        )

      case response.status
      when 200
        QualificationsApi::Teacher.new response.body
      when 404
        raise QualificationsApi::TeacherNotFoundError
      when 403
        raise QualificationsApi::ForbiddenError
      when 401
        raise QualificationsApi::InvalidTokenError
      else
        raise QualificationsApi::UnknownError, "API returned unhandled status #{response.status}"
      end
    end

    def teachers(date_of_birth:, last_name:)
      response =
        get(
          "v3/teachers",
          {
            dateOfBirth: date_of_birth.to_s,
            findBy: "LastNameAndDateOfBirth",
            lastName: last_name
          }
        )

      raise(QualificationsApi::InvalidTokenError) if response.status == 401

      results =
        response.body["results"].map do |teacher|
          QualificationsApi::Teacher.new(teacher)
        end

      [response.body["total"], results]
    end

    def bulk_teachers(queries: [])
      response = client.post("v3/persons/find", { persons: queries }) do |request|
        request.headers["X-Api-Version"] = "20240814"
      end
      response.body
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

    private

    def get(endpoint, options = {})
      client.get(endpoint, options)
    rescue Faraday::ConnectionFailed, Faraday::TimeoutError => e
      raise QualificationsApi::ApiError, "API connection failed: #{e.message}"
    end

    def valid_certificate_path?(path)
      path.start_with?("/v3/certificates")
    end
  end
end
