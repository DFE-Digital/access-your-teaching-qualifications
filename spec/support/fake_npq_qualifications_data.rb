module FakeNpqQualificationsData
  def quals_data(trn: nil)
    case trn
    when "1111111"
      {"data":
         {"trn": "1111111",
          "qualifications":[
            {"award_date":"2015-11-03","npq_type":"NPQML"},
            {"award_date":"2015-11-04","npq_type":"NPQSL"}
          ]
         }
      }
    when "111112"
      {"data":
         {"trn": "111112",
          "qualifications":[
            {"award_date": nil,"npq_type":"NPQML"},
          ]
         }
      }
    when "1212121"
      {"data":
         {"trn": "111112",
          "qualifications":[]
         }
      }
    when "1234567"
      {"data":
         {"trn": "1234567",
          "qualifications":[
            {"award_date":"2023-02-27","npq_type":"NPQEYL"}
          ]
         }
      }
    else
    {"data":
       {"trn": trn || "3000299",
        "qualifications":[
          {"award_date":"2023-02-27","npq_type":"NPQH"}
        ]
       }
    }
    end
  end

  def no_data
    {"data":
       {"trn": trn || "3000299",
        "qualifications":[]
       }
    }
  end
end