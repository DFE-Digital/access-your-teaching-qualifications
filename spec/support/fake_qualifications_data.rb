module FakeQualificationsData
  def quals_data(trn: nil, itt: true)
    {
      trn: trn || "3000299",
      dateOfBirth: "2000-01-01",
      firstName: "Terry",
      lastName: "Walsh",
      previousNames: [
        { first_name: "Terry", last_name: "Jones", middle_name: "" },
        { first_name: "Terry", last_name: "Smith", middle_name: "" }
      ],
      eyts: {
        awarded: "2022-04-01",
        statusDescription: "Qualified (trained in the UK)",
      },
      qts: {
        awarded: "2023-02-27",
        statusDescription: "Qualified (trained in the UK)",
        routes: {
          awarded_approved_count: "1"
        }
      },
      induction: {
        startDate: "2022-09-01",
        endDate: "2022-10-01",
        status: "Pass",
        statusDescription: "Passed Induction",
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
                qualification: {
                  name: "BA"
                },
                startDate: "2022-02-28",
                endDate: "2023-01-28",
                programmeType: "HEI",
                programmeTypeDescription: "Higher education institution",
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
          end
        ),
      mandatoryQualifications: [
        { awarded: "2023-02-28", specialism: "Visual impairment" },
        { awarded: "2022-01-01", specialism: "Hearing" }
      ],
      npqQualifications: [
        {
          awarded: "2023-02-27",
          certificateUrl: "/v3/certificates/npq/1",
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
            name: "National Professional Qualification (NPQ) for Early Years Leadership"
          }
        }
      ],
      alerts: if trn == "9876543"
  [ { alert_type: {alert_type_id: "40794ea8-eda2-40a8-a26a-5f447aae6c99"}, 
startDate: "2020-10-25" } ]
else
  []
end,
      qtlsStatus: "None"
    }
  end

  def no_data(trn:)
    {
      trn:,
      dateOfBirth: "2000-01-01",
      firstName: "Terry",
      lastName: "Walsh",
      previousNames: [],
      eyts: nil,
      qts: nil,
      induction: nil,
      initialTeacherTraining: nil,
      mandatoryQualifications: [],
      npqQualifications: [],
      alerts: [],
      qtlsStatus: nil,
    }
  end
end
