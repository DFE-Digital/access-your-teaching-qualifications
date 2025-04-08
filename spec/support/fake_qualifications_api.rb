require_relative "fake_qualifications_data"
require_relative "fake_qualifications_data_with_nulling"

class FakeQualificationsApi < Sinatra::Base
  include FakeQualificationsData

  get "/v3/person" do
    content_type :json

    case bearer_token
    when "token"
      quals_data.to_json
    when "no-itt-token"
      quals_data(trn: "1234567", itt: false).to_json
    when "nulled-quals-data"
      FakeQualificationsDataWithNulling.generate.to_json
    when "invalid-token"
      halt 401
    when "api-error"
      halt 500
    end
  end

  get "/v3/persons" do
    content_type :json

    case bearer_token
    when "token"
      case params["lastName"]
      when "No_match_last_name"
        { total: 0, results: [] }.to_json
      when "Restricted"
        {
          total: 1,
          results: [teacher_data(sanctions: true)]
        }.to_json
      when "Multiple_results"
        {
          total: 2,
          results: [teacher_data, additional_teacher]
        }.to_json
      when "No_data"
        {
          total: 1,
          results: [no_data]
        }.to_json
      else
        {
          total: 1,
          results: [teacher_data]
        }.to_json
      end
    when "invalid-token"
      halt 401
    end
  end

  get "/v3/persons/:trn" do
    content_type :json

    trn = params[:trn]
    case bearer_token
    when "token"
      case trn
      when "1234567"
        quals_data(trn: "1234567").to_json
      when "9876543"
        quals_data(trn:).to_json
      when "1212121"
        no_data.to_json
      else
        halt 404
      end
    when "invalid-token"
      halt 401
    end
  end

  post "/v3/persons/find" do
    content_type :json

    case bearer_token
    when "token"
      {
        results: [quals_data(trn: "9876543")],
        total: 1
      }.to_json
    when "invalid-token"
      halt 401
    when "forbidden"
      halt 403
    when "api-error"
      halt 500
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

  post "/v3/teacher/name-changes" do
    content_type :json

    { caseNumber: "CASE-TEST-123" }.to_json
  end

  post "/v3/teacher/date-of-birth-changes" do
    content_type :json

    { caseNumber: "CASE-TEST-123" }.to_json
  end

  private

  def teacher_data(sanctions: false, trn: "1234567")
    sanctions ? sanctions_data : no_sanctions_data(trn:)
  end

  def no_data
    no_sanctions_data(trn: "1212121")
  end

  def no_sanctions_data(trn:)
    {
      dateOfBirth: "2000-01-01",
      firstName: "Terry",
      lastName: "Walsh",
      middleName: "John",
      previousNames: [
        { first_name: "Terry", last_name: "Jones", middle_name: "" },
        { first_name: "Terry", last_name: "Smith", middle_name: "" }
      ],
      induction: {status: "None", end_date: nil, start_date: nil},
      alerts: [],
      trn:
    }
  end

  def additional_teacher
    {
      dateOfBirth: "1985-01-01",
      firstName: "Steven",
      lastName: "Toast",
      middleName: "Gonville",
      previousNames: [
        { first_name: "Stephen", last_name: "Toast", middle_name: "" },
      ],
      alerts: [],
      trn: "987654321"
    }
  end

  def sanctions_data
    {
      dateOfBirth: "2000-01-01",
      firstName: "Teacher",
      lastName: "Restricted",
      middleName: "",
      previousNames: [
        { first_name: "Terry", last_name: "Jones", middle_name: "" },
        { first_name: "Terry", last_name: "Smith", middle_name: "" }
      ],
      alerts: [
        {
          alert_type: {
            alert_type_id: "40794ea8-eda2-40a8-a26a-5f447aae6c99",
          },
          startDate: "2019-10-25"
        },
        {
          alert_type: {
            alert_type_id: "fa6bd220-61b0-41fc-9066-421b3b9d7885"
          },
          startDate: "2018-9-20"
        }
      ],
      trn: "9876543"
    }
  end

  def bearer_token
    auth_header = request.env.fetch("HTTP_AUTHORIZATION")
    auth_header.delete_prefix("Bearer ")
  end
end
