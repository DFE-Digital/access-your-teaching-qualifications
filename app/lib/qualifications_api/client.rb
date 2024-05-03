module QualificationsApi
  class InvalidCertificateUrlError < StandardError; end
  class ForbiddenError < StandardError; end
  class UnknownError < StandardError; end

  class Client
    TIMEOUT_IN_SECONDS = 5

    attr_reader :token

    def initialize(token:)
      @token = token
    end

    def certificate(name:, type:, url:)
      unless valid_certificate_path?(url)
        raise QualificationsApi::InvalidCertificateUrlError
      end

      response = client.get(url)

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
        client.get(
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
        client.get(
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

    def valid_certificate_path?(path)
      path.start_with?("/v3/certificates")
    end
  end
end
