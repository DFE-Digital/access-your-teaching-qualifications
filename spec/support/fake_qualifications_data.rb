module FakeQualificationsData
  def quals_data(trn: nil, rtps: true)
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
        holdsFrom: "2022-04-01",
        routes: [
          {
            "routeToProfessionalStatusType" => {
              "routeToProfessionalStatusTypeId" => "eyts-route-type-id-22222",
              "name" => "BA",
              "professionalStatusType" => "EarlyYearsTeacherStatus"
            }
          }
        ]
      },
      qts: {
        holdsFrom: "2023-02-27",
        "routes" => [
          {
            "routeToProfessionalStatusType" => {
              "routeToProfessionalStatusTypeId" => "qts-route-type-id-11111",
              "name" => "Initial teacher training (ITT)",
              "professionalStatusType" => "QualifiedTeacherStatus"
            }
          }
        ],
        awarded_approved_count: "1"
      },
      induction: {
        startDate: "2022-09-01",
        completedDate: "2022-10-01",
        status: "Passed",
        exemptionReasons: [
          {
            inductionExemptionReasonId: "induction-exemption-reason-id-33333",
            "name": "Gained QTS before 1999"
          }
        ]
      },
      "routesToProfessionalStatuses": [rtps ? build_rtps : nil].compact,
      mandatoryQualifications: [
        { endDate: "2023-02-28", specialism: "Visual impairment", mandatoryQualificationId: 1 },
        { endDate: "2022-01-01", specialism: "Hearing", mandatoryQualificationId: 1 }
      ],
      alerts: fake_alerts(trn),
      qtlsStatus: "None"
    }
  end

  def build_rtps
    {
      "routeToProfessionalStatusId": "qts-route-id-11111",
      "routeToProfessionalStatusType": {
        "routeToProfessionalStatusTypeId": "qts-route-type-id-11111",
        "name": "Initial teacher training (ITT)",
        "professionalStatusType": "QualifiedTeacherStatus"
      },
      "status": "InTraining",
      "holdsFrom": "2023-02-27",
      "trainingStartDate": "2022-02-28",
      "trainingEndDate": "2023-01-28",
      "trainingSubjects": [
        {
          "reference": "12345",
          "name": "Business Studies"
        }
      ],
      "trainingAgeSpecialism": {
        "type": "Range",
        "from": 7,
        "to": 14
      },
      "trainingCountry": {
        "reference": "string",
        "name": "United Kingdom"
      },
      "trainingProvider": {
        "ukprn": "12345",
        "name": "Earl Spencer Primary School"
      },
      "degreeType": {
        "degreeTypeId": "degree-type-id-44444",
        "name": "BA"
      },
      "inductionExemption": {
        "isExempt": true,
        "exemptionReasons": [
          {
            "inductionExemptionReasonId": "induction-exemption-reason-id-33333",
            "name": "string"
          }
        ]
      }
    }
  end

  def fake_alerts(trn)
    return [] unless trn == "9876543"

    [
      {
        alert_type: { alert_type_id: "40794ea8-eda2-40a8-a26a-5f447aae6c99" },
        startDate: "2020-10-25"
      }
    ]
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
      mandatoryQualifications: [],
      routesToProfessionalStatuses: [],
      alerts: [],
      qtlsStatus: nil,
    }
  end
end
