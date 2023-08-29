class FakeQualificationsApi < Sinatra::Base
  get "/v3/teacher" do
    content_type :json

    case bearer_token
    when "token"
      quals_data
    when "no-itt-token"
      quals_data(trn: "1234567", itt: false)
    when "invalid-token"
      halt 401
    end
  end

  get "/v3/teachers" do
    content_type :json

    case bearer_token
    when "token"
      {
        total: 1,
        results: [teacher_data(sanctions: params["lastName"] == "Restricted")]
      }.to_json
    when "invalid-token"
      halt 401
    end
  end

  get "/v3/teachers/:trn" do
    content_type :json

    trn = params[:trn]
    case bearer_token
    when "token"
      if trn == "1234567"
        quals_data(trn: "1234567")
      elsif trn == "987654321"
        quals_data(trn:)
      else
        halt 404
      end
    when "invalid-token"
      halt 401
    end
  end

  get "/v3/certificates/npq/:id" do
    content_type "application/pdf"
    attachment "npq_certificate.pdf"

    case bearer_token
    when "token"
      if params[:id] == "missing"
        halt 404
      else
        "pdf data"
      end
    when "invalid-token"
      halt 401
    end
  end

  get "/v3/certificates/:id" do
    content_type "application/pdf"
    attachment "#{params[:id]}_certificate.pdf"

    case bearer_token
    when "token"
      "pdf data"
    when "invalid-token"
      halt 401
    end
  end

  private

  def teacher_data(sanctions: false, trn: "1234567")
    sanctions ? sanctions_data : no_sanctions_data(trn:)
  end

  def no_sanctions_data(trn:)
    {
      dateOfBirth: "2000-01-01",
      firstName: "Terry",
      lastName: "Walsh",
      middleName: "John",
      sanctions: [],
      trn:
    }
  end

  def sanctions_data
    {
      dateOfBirth: "2000-01-01",
      firstName: "Teacher",
      lastName: "Restricted",
      middleName: "",
      sanctions: ["C2"],
      trn: "987654321"
    }
  end

  def quals_data(trn: nil, itt: true)
    {
      trn: trn || "3000299",
      firstName: "Terry",
      lastName: "Walsh",
      eyts: {
        awarded: "2022-04-01",
        certificateUrl: trn ? nil : "/v3/certificates/eyts"
      },
      qts: {
        awarded: "2023-02-27",
        certificateUrl: trn ? nil : "/v3/certificates/qts"
      },
      induction: {
        startDate: "2022-09-01",
        endDate: "2022-10-01",
        status: "pass",
        certificateUrl: "/v3/certificates/induction",
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
      initialTeacherTraining:
        (
          if !itt
            []
          else
            [
              {
                ageRange: {
                  description: "10 to 16 years"
                },
                endDate: "2023-01-28",
                programmeType: "HEI",
                programmeTypeDescription: "Higher education institution",
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
            ]
          end
        ),
      mandatoryQualifications: [
        { awarded: "2023-02-28", specialism: "Visual impairment" }
      ],
      npqQualifications: [
        {
          awarded: "2023-02-27",
          certificateUrl: trn ? nil : "/v3/certificates/npq/1",
          type: {
            code: "NPQH",
            name: "NPQ headteacher"
          }
        },
        {
          awarded: "2023-01-27",
          certificateUrl: "/v3/certificates/npq/missing",
          type: {
            code: "NPQSL",
            name: "NPQ senior leadership"
          }
        }
      ],
      sanctions: trn == "987654321" ? ["C2"] : []
    }.to_json
  end

  def bearer_token
    auth_header = request.env.fetch("HTTP_AUTHORIZATION")
    auth_header.delete_prefix("Bearer ")
  end
end
