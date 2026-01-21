module FakeQualificationsData
  def quals_data(trn: nil, rtps: true, qts_via_qtls: true, induction_status: "Passed")
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
      qts: qts_data(qts_via_qtls:),
      induction: induction_data(induction_status),
      "routesToProfessionalStatuses": [rtps ? build_rtps : nil].compact.flatten,
      mandatoryQualifications: [
        { endDate: "2023-02-28", specialism: "Visual impairment", mandatoryQualificationId: 1 },
        { endDate: "2022-01-01", specialism: "Hearing", mandatoryQualificationId: 1 }
      ],
      alerts: fake_alerts(trn),
      qtlsStatus: qts_via_qtls ? "Active" : "None"
    }
  end

  def induction_data(induction_status)
    if induction_status == "Failed"
      return {
        startDate: "2022-09-01",
        completedDate: nil,
        status: induction_status,
        exemptionReasons: []
      }
    end

    {
      startDate: "2022-09-01",
      completedDate: "2022-10-01",
      status: induction_status,
      exemptionReasons: [
        {
          inductionExemptionReasonId: "induction-exemption-reason-id-33333",
          "name": "Gained QTS before 1999"
        }
      ]
    }
  end

  def qts_data(qts_via_qtls:)
    route = if qts_via_qtls
      {
        "routeToProfessionalStatusType" => {
          "routeToProfessionalStatusTypeId" => QualificationsApi::Teacher::QTLS_ROUTE_ID,
          "name" => "string",
          "professionalStatusType" => "QualifiedTeacherStatus"
        }
      }
    else
      {
        "routeToProfessionalStatusType" => {
          "routeToProfessionalStatusTypeId" => "qts-route-type-id-11111",
          "name" => "Initial teacher training (ITT)",
          "professionalStatusType" => "QualifiedTeacherStatus"
        }
      }
    end

    {
      holdsFrom: "2023-02-27",
      "routes" => [route],
      awarded_approved_count: "1"
    }
  end

  def bulk_quals_data(trn: nil)
    {
      results: [quals_data(trn:, rtps: true)],
      total: 1
    }
  end

  def build_rtps
    [
      {
        "routeToProfessionalStatusId": "qts-route-id-11111",
        "routeToProfessionalStatusType": {
          "routeToProfessionalStatusTypeId": "qts-route-type-id-11111",
          "name": "Initial teacher training (ITT)",
          "professionalStatusType": "QualifiedTeacherStatus"
        },
        "status": "Holds",
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
      },
      {
        "routeToProfessionalStatusId": "other-route-id-11111",
        "routeToProfessionalStatusType": {
          "routeToProfessionalStatusTypeId": "other-route-type-id-11111",
          "name": "Non-held Route",
          "professionalStatusType": "QualifiedTeacherStatus"
        },
        "status": "InTraining",
        "holdsFrom": nil,
        "trainingStartDate": "2022-02-28",
        "trainingEndDate": "2030-01-28",
        "trainingSubjects": [
          {
            "reference": "12345",
            "name": "Business Studies"
          }
        ],
        "trainingAgeSpecialism": {
          "type": "Range",
          "from": 15,
          "to": 18
        },
        "trainingCountry": {
          "reference": "string",
          "name": "United Kingdom"
        },
        "trainingProvider": {
          "ukprn": "23456",
          "name": "Earl Spencer Secondary School"
        },
        "degreeType": {
          "degreeTypeId": "degree-type-id-55555",
          "name": "MA"
        },
        "inductionExemption": {
          "isExempt": false,
          "exemptionReasons": []
        }
      }
    ]
  end

  def fake_alerts(trn)
    return [] unless trn == "9876543"

    [
      {
        alert_type: {
          alert_type_id: "ed0cd700-3fb2-4db0-9403-ba57126090ed",
        },
        startDate: "2019-10-25"
      },
      {
        alert_type: {
          alert_type_id: "fa6bd220-61b0-41fc-9066-421b3b9d7885"
        },
        startDate: "2018-9-20"
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
