module FakeQualificationsData
  def quals_data(trn: nil, itt: true)
    {
      trn: trn || "3000299",
      dateOfBirth: "2000-01-01",
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
        { awarded: "2023-02-28", specialism: "Visual impairment" },
        { awarded: "2022-01-01", specialism: "Hearing" }
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
      sanctions: trn == "987654321" ? [ { code: "C2", startDate: "2020-10-25" } ] : []
    }
  end
end
