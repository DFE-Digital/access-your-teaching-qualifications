class FakeQualificationsApi < Sinatra::Base
  get "/v3/teacher" do
    content_type :json

    case bearer_token
    when "token"
      {
        trn: "3000299",
        firstName: "Terry",
        lastName: "Walsh",
        eyts: {
          awarded: "2022-04-01",
          certificateUrl: "http://example.com/v3/certificates/eyts"
        },
        qts: {
          awarded: "2023-02-27"
        },
        induction: {
          startDate: "2022-09-01",
          endDate: "2022-10-01",
          status: "pass",
          certificateUrl: "string",
          periods: [
            {
              startDate: "2022-09-01",
              endDate: "2022-10-01",
              terms: 1,
              appropriateBody: {
                name: "Induction body"
              }
            }
          ]
        },
        initialTeacherTraining: [
          {
            ageRange: {
              description: "10 to 16 years"
            },
            endDate: "2023-01-28",
            programmeType: "HEI",
            provider: {
              name: "Earl Spencer Primary School",
              ukprn: nil
            },
            qualification: {
              name: "BA"
            },
            result: "Pass",
            startDate: "2022-02-28",
            subjects: [{ code: "100079", name: "business studies" }]
          }
        ],
        npqQualifications: [
          {
            awarded: "2023-02-27",
            certificateUrl: "/v3/certificates/npq/1",
            type: {
              code: "NPQH",
              name: "NPQ headteacher"
            }
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

  get "/v3/certificates/eyts" do
    content_type "application/pdf"
    attachment "eyts_certificate.pdf"

    case bearer_token
    when "token"
      "pdf data"
    when "invalid-token"
      halt 401
    end
  end

  get "/v3/certificates/npq/:id" do
    content_type "application/pdf"
    attachment "npq_certificate.pdf"

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
