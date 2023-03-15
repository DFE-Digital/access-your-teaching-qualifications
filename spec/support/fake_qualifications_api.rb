class FakeQualificationsApi < Sinatra::Base
  get "/v3/teacher" do
    content_type :json

    case bearer_token
    when "token"
      {
        trn: "3000299",
        firstName: "Terry",
        lastName: "Walsh",
        qts: {
          awarded: "2023-02-27"
        },
        initialTeacherTraining: [
          {
            qualification: {
              name: "BA"
            },
            startDate: "2022-02-28",
            endDate: "2023-01-28",
            programmeType: "HEI",
            result: "Pass",
            ageRange: {
              description: "10 to 16 years"
            },
            provider: {
              name: "Earl Spencer Primary School",
              ukprn: nil
            },
            subjects: [{ code: "100079", name: "business studies" }]
          }
        ]
      }.to_json
    when "invalid-token"
      halt 401
    end
  end

  get "/v3/certificates/qts" do
    content_type "application/pdf"
    attachment "qts_certificate.pdf"

    case bearer_token
    when "token"
      "pdf data"
    when "invalid-token"
      halt 401
    end
  end

  private

  def bearer_token
    auth_header = request.env.fetch("HTTP_AUTHORIZATION")
    auth_header.delete_prefix("Bearer ")
  end
end
