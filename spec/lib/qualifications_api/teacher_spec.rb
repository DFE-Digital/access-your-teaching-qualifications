require "rails_helper"

RSpec.describe QualificationsApi::Teacher, type: :model do
  let(:api_data) do
    {
      "trn" => "1111111",
      "induction" => {
        "startDate" => "2015-01-01",
        "endDate" => "2015-07-01",
        "status" => "Complete",
        "certificateUrl" => "https",
        "periods" => [
          {
            "startDate" => "string",
            "endDate" => "string",
            "terms" => "integer",
            "appropriateBody" => {
              "name" => "string"
            }
          }
        ]
      },
      "routesToProfessionalStatuses" => [
        {
          "routeToProfessionalStatusId" => "eyts-route-id-22222",
          "routeToProfessionalStatusType" => {
            "routeToProfessionalStatusTypeId" => "eyts-route-type-id-22222",
            "name" => "BA",
            "professionalStatusType" => "EarlyYearsTeacherStatus"
          },
          "status" => "Holds",
          "holdsFrom" => "2012-02-2",
          "trainingStartDate" => "2011-01-17",
          "trainingEndDate" => "2012-02-2",
          "trainingSubjects" => [
            {
              "reference" => "100079",
              "name" => "Business Studies"
            }
          ],
          "trainingAgeSpecialism" => {
            "type" => "Range",
            "from" => 3,
            "to" => 7
          },
          "trainingCountry" => {
            "reference" => "string",
            "name" => "United Kingdom"
          },
          "trainingProvider" => {
            "ukprn" => "12345",
            "name" => "Earl Spencer Primary School"
          },
          "degreeType" => {
            "degreeTypeId" => "degree-type-id-44444",
            "name" => "BA"
          },
          "inductionExemption" => {
            "isExempt" => true,
            "exemptionReasons" => [
              {
                "inductionExemptionReasonId" => "induction-exemption-reason-id-33333",
                "name" => "string"
              }
            ]
          }
        },
        {
          "routeToProfessionalStatusId" => "qts-route-id-11111",
          "routeToProfessionalStatusType" => {
            "routeToProfessionalStatusTypeId" => "qts-route-type-id-11111",
            "name" => "BA",
            "professionalStatusType" => "QualifiedTeacherStatus"
          },
          "status" => "Holds",
          "holdsFrom" => "2013-01-28",
          "trainingStartDate" => "2012-02-28",
          "trainingEndDate" => "2013-01-28",
          "trainingSubjects" => [
            {
              "reference" => "100079",
              "name" => "Business Studies"
            }
          ],
          "trainingAgeSpecialism" => {
            "type" => "Range",
            "from" => 10,
            "to" => 16
          },
          "trainingCountry" => {
            "reference" => "string",
            "name" => "United Kingdom"
          },
          "trainingProvider" => {
            "ukprn" => "12345",
            "name" => "Earl Spencer Primary School"
          },
          "degreeType" => {
            "degreeTypeId" => "degree-type-id-44444",
            "name" => "BA"
          },
          "inductionExemption" => {
            "isExempt" => true,
            "exemptionReasons" => [
              {
                "inductionExemptionReasonId" => "induction-exemption-reason-id-33333",
                "name" => "string"
              }
            ]
          }
        },
      ],
      "qts" => {
        "holdsFrom" => "2015-11-01",
        "routes" => [
          {
            "routeToProfessionalStatusType" => {
              "routeToProfessionalStatusTypeId" => "qts-route-type-id-11111",
              "name" => "string",
              "professionalStatusType" => "QualifiedTeacherStatus"
            }
          }
        ]
      },
      "eyts" => {
        "holdsFrom" => "2015-11-02",
        "routes" => [
          {
            "routeToProfessionalStatusType" => {
              "routeToProfessionalStatusTypeId" => "eyts-route-type-id-22222",
              "name" => "BA",
              "professionalStatusType" => "EarlyYearsTeacherStatus"
            }
          }
        ]
      },
      "mandatoryQualifications" => [
        { "endDate" => "2013-06-01", "specialism" => "Visual Impairment", "mandatoryQualificationId" => 1 }
      ],
    }
  end

  describe "#qualifications" do
    subject(:qualifications) { teacher.qualifications }

    let(:teacher) { described_class.new(api_data) }

    it "sorts the qualifications in reverse chronological order by date of award" do
      expect(qualifications.map(&:type)).to eq(
        %i[NPQSL NPQML mandatory induction qts qts_rtps eyts eyts_rtps]
      )
    end

    it "orders QTS RTPS qualifications before EYTS RTPS qualifications" do
      rtps_qualifications = qualifications.select { |q| q.type == :eyts_rtps || q.type == :qts_rtps }
      expect(rtps_qualifications.map do |q|
 q.details.route_to_professional_status_type.professional_status_type end).to eq(
        %w[QualifiedTeacherStatus EarlyYearsTeacherStatus]
      )
    end

    it "designates RTPS qualifications as QTS if no programme type is present" do
      rtps_qualification = api_data["routesToProfessionalStatuses"].first
      rtps_qualification["routeToProfessionalStatusType"]["routeToProfessionalStatusTypeId"] = nil
      api_data["routesToProfessionalStatuses"] = [rtps_qualification]

      expect(qualifications.map(&:type)).to eq(
        %i[NPQSL NPQML mandatory induction qts qts_rtps eyts other_rtps]
      )
    end

    context "RTPS result field" do
      before do
        api_data["routesToProfessionalStatuses"].each { |rtps| rtps["status"] = "DeferredForSkillsTests" }
      end

      it "returns human readable values" do
        expect(qualifications.find { |q| q.type == :qts_rtps }.details.status).to eq("Deferred for skills tests")
      end
    end

    context "when a qualification has no awarded date" do
      let(:api_data) do
        {
          "trn" => "1111111",
          "induction" => {
            "startDate" => "2015-01-01",
            "endDate" => "2015-07-01",
            "status" => "Complete",
            "certificateUrl" => "https",
            "periods" => [
              {
                "startDate" => "string",
                "endDate" => "string",
                "terms" => "integer",
                "appropriateBody" => {
                  "name" => "string"
                }
              }
            ]
          },
          "routesToProfessionalStatuses" => [
            {
              "routeToProfessionalStatusId" => "eyts-route-id-22222",
              "routeToProfessionalStatusType" => {
                "routeToProfessionalStatusTypeId" => "eyts-route-type-id-22222",
                "name" => "BA",
                "professionalStatusType" => "EarlyYearsTeacherStatus"
              },
              "status" => "Holds",
              "holdsFrom" => nil,
              "trainingStartDate" => "2011-01-17",
              "trainingEndDate" => "2012-02-2",
              "trainingSubjects" => [
                {
                  "reference" => "100079",
                  "name" => "Business Studies"
                }
              ],
              "trainingAgeSpecialism" => {
                "type" => "Range",
                "from" => 3,
                "to" => 7
              },
              "trainingCountry" => {
                "reference" => "string",
                "name" => "United Kingdom"
              },
              "trainingProvider" => {
                "ukprn" => "12345",
                "name" => "Earl Spencer Primary School"
              },
              "degreeType" => {
                "degreeTypeId" => "degree-type-id-44444",
                "name" => "BA"
              },
              "inductionExemption" => {
                "isExempt" => true,
                "exemptionReasons" => [
                  {
                    "inductionExemptionReasonId" => "induction-exemption-reason-id-33333",
                    "name" => "string"
                  }
                ]
              }
            },
            {
              "routeToProfessionalStatusId" => "qts-route-id-11111",
              "routeToProfessionalStatusType" => {
                "routeToProfessionalStatusTypeId" => "qts-route-type-id-11111",
                "name" => "BA",
                "professionalStatusType" => "QualifiedTeacherStatus"
              },
              "status" => "Holds",
              "holdsFrom" => "2013-01-28",
              "trainingStartDate" => "2012-02-28",
              "trainingEndDate" => "2013-01-28",
              "trainingSubjects" => [
                {
                  "reference" => "100079",
                  "name" => "Business Studies"
                }
              ],
              "trainingAgeSpecialism" => {
                "type" => "Range",
                "from" => 10,
                "to" => 16
              },
              "trainingCountry" => {
                "reference" => "string",
                "name" => "United Kingdom"
              },
              "trainingProvider" => {
                "ukprn" => "12345",
                "name" => "Earl Spencer Primary School"
              },
              "degreeType" => {
                "degreeTypeId" => "degree-type-id-44444",
                "name" => "BA"
              },
              "inductionExemption" => {
                "isExempt" => true,
                "exemptionReasons" => [
                  {
                    "inductionExemptionReasonId" => "induction-exemption-reason-id-33333",
                    "name" => "string"
                  }
                ]
              }
            },
          ],
          "qts" => {
            "holdsFrom" => "2015-11-01",
            "routes" => [
              {
                "routeToProfessionalStatusType" => {
                  "routeToProfessionalStatusTypeId" => "qts-route-type-id-11111",
                  "name" => "string",
                  "professionalStatusType" => "QualifiedTeacherStatus"
                }
              }
            ]
          },
          "eyts" => {
            "holdsFrom" => "2015-11-02",
            "routes" => [
              {
                "routeToProfessionalStatusType" => {
                  "routeToProfessionalStatusTypeId" => "eyts-route-type-id-22222",
                  "name" => "BA",
                  "professionalStatusType" => "EarlyYearsTeacherStatus"
                }
              }
            ]
          },
          "mandatoryQualifications" => [
            { "endDate" => "2013-06-01", "specialism" => "Visual Impairment", "mandatoryQualificationId" => 1 }
          ],
        }
      end

      it "sorts the qualifications in reverse order by date of award and type" do
        expect(qualifications.map(&:type)).to eq([:NPQSL, :NPQML, :mandatory, :induction, :qts, :qts_rtps, :eyts, 
:eyts_rtps])
      end
    end

    context "when there are no MQs returned" do
      let(:api_data) { {} }

      it "returns an empty array" do
        expect(qualifications).to eq([])
      end
    end

    context "when QTS and RTPS share the same date" do
      let(:api_data) do
        {
          "trn" => "1111111",
          "induction" => {
            "startDate" => "2015-01-01",
            "endDate" => "2015-07-01",
            "status" => "Complete",
            "certificateUrl" => "https",
            "periods" => [
              {
                "startDate" => "string",
                "endDate" => "string",
                "terms" => "integer",
                "appropriateBody" => {
                  "name" => "string"
                }
              }
            ]
          },
          "routesToProfessionalStatuses" => [
            {
              "routeToProfessionalStatusId" => "eyts-route-id-22222",
              "routeToProfessionalStatusType" => {
                "routeToProfessionalStatusTypeId" => "eyts-route-type-id-22222",
                "name" => "BA",
                "professionalStatusType" => "EarlyYearsTeacherStatus"
              },
              "status" => "Holds",
              "holdsFrom" => "2012-02-2",
              "trainingStartDate" => "2011-01-17",
              "trainingEndDate" => "2012-02-2",
              "trainingSubjects" => [
                {
                  "reference" => "100079",
                  "name" => "Business Studies"
                }
              ],
              "trainingAgeSpecialism" => {
                "type" => "Range",
                "from" => 3,
                "to" => 7
              },
              "trainingCountry" => {
                "reference" => "string",
                "name" => "United Kingdom"
              },
              "trainingProvider" => {
                "ukprn" => "12345",
                "name" => "Earl Spencer Primary School"
              },
              "degreeType" => {
                "degreeTypeId" => "degree-type-id-44444",
                "name" => "BA"
              },
              "inductionExemption" => {
                "isExempt" => true,
                "exemptionReasons" => [
                  {
                    "inductionExemptionReasonId" => "induction-exemption-reason-id-33333",
                    "name" => "string"
                  }
                ]
              }
            },
            {
              "routeToProfessionalStatusId" => "qts-route-id-11111",
              "routeToProfessionalStatusType" => {
                "routeToProfessionalStatusTypeId" => "qts-route-type-id-11111",
                "name" => "Initial teacher training (ITT)",
                "professionalStatusType" => "QualifiedTeacherStatus"
              },
              "status" => "InTraining",
              "holdsFrom" => "2015-11-01",
              "trainingStartDate" => "2014-11-01",
              "trainingEndDate" => "2015-11-01",
              "trainingSubjects" => [
                {
                  "reference" => "12345",
                  "name" => "Business Studies"
                }
              ],
              "trainingAgeSpecialism" => {
                "type" => "Range",
                "from" => 7,
                "to" => 14
              },
              "trainingCountry" => {
                "reference" => "string",
                "name" => "United Kingdom"
              },
              "trainingProvider" => {
                "ukprn" => "12345",
                "name" => "Earl Spencer Primary School"
              },
              "degreeType" => {
                "degreeTypeId" => "degree-type-id-44444",
                "name" => "BA"
              },
              "inductionExemption" => {
                "isExempt" => true,
                "exemptionReasons" => [
                  {
                    "inductionExemptionReasonId" => "induction-exemption-reason-id-33333",
                    "name" => "string"
                  }
                ]
              }
            }
          ],
          "qts" => {
            "holdsFrom" => "2015-11-01",
            "routes" => [
              {
                "routeToProfessionalStatusType" => {
                  "routeToProfessionalStatusTypeId" => "qts-route-type-id-11111",
                  "name" => "string",
                  "professionalStatusType" => "QualifiedTeacherStatus"
                }
              }
            ]
          },
          "eyts" => {
            "holdsFrom" => "2015-11-02",
            "routes" => [
              {
                "routeToProfessionalStatusType" => {
                  "routeToProfessionalStatusTypeId" => "eyts-route-type-id-22222",
                  "name" => "string",
                  "professionalStatusType" => "EarlyYearsTeacherStatus"
                }
              }
            ]
          },
          "mandatoryQualifications" => [
            { "endDate" => "2013-06-01", "specialism" => "Visual Impairment", "mandatoryQualificationId" => 1 }
          ],
        }
      end

      it "the QTS gets priority in the sort order" do
        expect(qualifications.map(&:type)).to eq([:NPQSL, :NPQML, :mandatory, :induction, :qts, :qts_rtps, :eyts, 
:eyts_rtps])
      end
    end

    context "when programmeType is an Integer" do
      let(:api_data) do
        {
          "trn" => "1111111",
          "induction" => {
            "startDate" => "2015-01-01",
            "endDate" => "2015-07-01",
            "status" => "Complete",
            "certificateUrl" => "https",
            "periods" => [
              {
                "startDate" => "string",
                "endDate" => "string",
                "terms" => "integer",
                "appropriateBody" => {
                  "name" => "string"
                }
              }
            ]
          },
          "routesToProfessionalStatuses" => [
            {
              "routeToProfessionalStatusId" => "eyts-route-id-22222",
              "routeToProfessionalStatusType" => {
                "routeToProfessionalStatusTypeId" => "eyts-route-type-id-22222",
                "name" => "BA",
                "professionalStatusType" => "EarlyYearsTeacherStatus"
              },
              "status" => "Holds",
              "holdsFrom" => "2012-02-2",
              "trainingStartDate" => "2011-01-17",
              "trainingEndDate" => "2012-02-2",
              "trainingSubjects" => [
                {
                  "reference" => "100079",
                  "name" => "Business Studies"
                }
              ],
              "trainingAgeSpecialism" => {
                "type" => "Range",
                "from" => 3,
                "to" => 7
              },
              "trainingCountry" => {
                "reference" => "string",
                "name" => "United Kingdom"
              },
              "trainingProvider" => {
                "ukprn" => "12345",
                "name" => "Earl Spencer Primary School"
              },
              "degreeType" => {
                "degreeTypeId" => "degree-type-id-44444",
                "name" => "BA"
              },
              "inductionExemption" => {
                "isExempt" => true,
                "exemptionReasons" => [
                  {
                    "inductionExemptionReasonId" => "induction-exemption-reason-id-33333",
                    "name" => "string"
                  }
                ]
              }
            },
            {
              "routeToProfessionalStatusId" => "qts-route-id-11111",
              "routeToProfessionalStatusType" => {
                "routeToProfessionalStatusTypeId" => "qts-route-type-id-11111",
                "name" => "Initial teacher training (ITT)",
                "professionalStatusType" => "QualifiedTeacherStatus"
              },
              "status" => "InTraining",
              "holdsFrom" => "2015-11-01",
              "trainingStartDate" => "2014-11-01",
              "trainingEndDate" => "2015-11-01",
              "trainingSubjects" => [
                {
                  "reference" => "12345",
                  "name" => "Business Studies"
                }
              ],
              "trainingAgeSpecialism" => {
                "type" => "Range",
                "from" => 7,
                "to" => 14
              },
              "trainingCountry" => {
                "reference" => "string",
                "name" => "United Kingdom"
              },
              "trainingProvider" => {
                "ukprn" => "12345",
                "name" => "Earl Spencer Primary School"
              },
              "degreeType" => {
                "degreeTypeId" => "degree-type-id-44444",
                "name" => "BA"
              },
              "inductionExemption" => {
                "isExempt" => true,
                "exemptionReasons" => [
                  {
                    "inductionExemptionReasonId" => "induction-exemption-reason-id-33333",
                    "name" => "string"
                  }
                ]
              }
            }
          ],
          "qts" => {
            "holdsFrom" => "2015-11-01",
            "routes" => [
              {
                "routeToProfessionalStatusType" => {
                  "routeToProfessionalStatusTypeId" => "qts-route-type-id-11111",
                  "name" => "string",
                  "professionalStatusType" => "QualifiedTeacherStatus"
                }
              }
            ]
          },
          "eyts" => {
            "holdsFrom" => "2015-11-02",
            "routes" => [
              {
                "routeToProfessionalStatusType" => {
                  "routeToProfessionalStatusTypeId" => "eyts-route-type-id-22222",
                  "name" => "string",
                  "professionalStatusType" => "EarlyYearsTeacherStatus"
                }
              }
            ]
          },
          "mandatoryQualifications" => [
            { "endDate" => "2013-06-01", "specialism" => "Visual Impairment", "mandatoryQualificationId" => 1 }
          ],
        }
      end

      it "the QTS gets priority in the sort order" do
        expect(qualifications.map(&:type)).to eq([:NPQSL, :NPQML, :mandatory, :induction, :qts, :qts_rtps, :eyts, 
:eyts_rtps])
      end
    end
  end

  describe "#name" do
    let(:api_data) do
      {
        "firstName" => "Jane",
        "middleName" => "Smith",
        "lastName" => "Jones"
      }
    end
    let(:teacher) { described_class.new(api_data) }

    it "returns the full name" do
      expect(teacher.name).to eq("Jane Smith Jones")
    end
  end

  describe "#previous_names" do
    let(:api_data) do
      {
        "firstName" => "Jane",
        "middleName" => "Smith",
        "lastName" => "Jones",
        "previousNames" => [
          {
            "firstName" => "John",
            "middleName" => "Smith",
            "lastName" => "DOE",
          },
          {
            "firstName" => "Johan",
            "middleName" => "Smith",
            "lastName" => "DoE",
          },
          {
            "firstName" => "Johan",
            "middleName" => "Smith",
            "lastName" => "Johnson",
          },
          {
            "firstName" => "Johan",
            "middleName" => "Smith",
            "lastName" => nil,
          },
          {
            "firstName" => "Jim",
            "middleName" => "Smith",
            "lastName" => "JONES",
          },
        ]
      }
    end
    let(:teacher) { described_class.new(api_data) }

    it "returns an array of previous names" do
      expect(teacher.previous_names).to eq(
        %w[Doe Johnson]
      )
    end

    context "when there are no previous names" do
      let(:api_data) do
        {
          "firstName" => "Jane",
          "middleName" => "Smith",
          "lastName" => "Jones",
          "previousNames" => []
        }
      end

      it "returns an empty array" do
        expect(teacher.previous_names).to eq([])
      end
    end
  end

  describe "qts_awarded?" do
    let(:teacher) { described_class.new(api_data) }

    context "qts awarded timestamp is present" do
      let(:api_data) { { "qts" => { "holdsFrom" => "2013-01-28", } } }

      it "returns true" do
        expect(teacher.qts_awarded?).to eq true
      end
    end

    context "qts awarded timestamp is blank" do
      let(:api_data) { { "qts" => {} } }

      it "returns false" do
        expect(teacher.qts_awarded?).to eq false
      end
    end
  end

  describe "passed_induction?" do
    let(:teacher) { described_class.new(api_data) }

    context "induction status is 'Pass'" do
      let(:api_data) { { "induction" => { "status" => "Passed", } } }

      it "returns true" do
        expect(teacher.passed_induction?).to eq true
      end
    end

    context "induction status is anything other than 'Pass'" do
      let(:api_data) { { "induction" => { "status" => "Failed", } } }

      it "returns false" do
        expect(teacher.passed_induction?).to eq false
      end
    end

    context "induction status is blank" do
      let(:api_data) { { "induction" => {} } }

      it "returns false" do
        expect(teacher.passed_induction?).to eq false
      end
    end
  end

  describe "#pending_name_change?" do
    let(:teacher) { described_class.new(api_data) }

    context "pendingNameChange field is false" do
      let(:api_data) { { "pendingNameChange" => false } }

      it "returns false" do
        expect(teacher.pending_name_change?).to eq false
      end
    end

    context "pendingNameChange field is true" do
      let(:api_data) { { "pendingNameChange" => true } }

      it "returns true" do
        expect(teacher.pending_name_change?).to eq true
      end
    end
  end

  describe "#pending_date_of_birth_change?" do
    let(:teacher) { described_class.new(api_data) }

    context "pendingDateOfBirthChange field is false" do
      let(:api_data) { { "pendingDateOfBirthChange" => false } }

      it "returns false" do
        expect(teacher.pending_date_of_birth_change?).to eq false
      end
    end

    context "pendingDateOfBirthChange field is true" do
      let(:api_data) { { "pendingDateOfBirthChange" => true } }

      it "returns true" do
        expect(teacher.pending_date_of_birth_change?).to eq true
      end
    end
  end

  describe '#no_restrictions?' do
    subject(:no_restrictions) { teacher.no_restrictions? }

    let(:teacher) { described_class.new(api_data) }

    it { is_expected.to be_truthy }

    context "when there are sanctions that are not prohibited" do
      let(:api_data) do
        {
          "alerts" => [
            "alert_type" => {
              "alert_type_id" => "7924fe90-483c-49f8-84fc-674feddba848"
            }, 
            "start_date" => "2024-01-01" 
          ]
        }
      end

      it { is_expected.to be_truthy }
    end

    context "when there are sanctions not listed in the Sanction model" do
      let(:api_data) do
        {
          "alerts" => [
            "alert_type" => {
            "alert_type_id" => "Nonsense", "start_date" => "2024-01-01" 
          },
          ]
        }
      end

      it { is_expected.to be_truthy }
    end

    context "when there are sanctions that are prohibited" do
      let(:api_data) do
        {
          "alerts" => [
            "alert_type" =>  {
              "alert_type_id" => "1a2b06ae-7e9f-4761-b95d-397ca5da4b13"
            },
            "start_date" => "2024-01-01" 
          ]
        }
      end

      it { is_expected.to be_falsey }
    end

    context "when there are sanctions that have an end date" do
      let(:api_data) do
        {
          "alerts" => [
            "alert_type" =>  {
              "alert_type_id" => "1a2b06ae-7e9f-4761-b95d-397ca5da4b13"
            },
            "start_date" => "2024-01-01",
            "end_date" => "2025-01-02",
          ]
        }
      end

      it { is_expected.to be_truthy }
    end
  end
end
