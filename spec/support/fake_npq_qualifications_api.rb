require_relative "fake_npq_qualifications_data"

class FakeNpqQualificationsApi < Sinatra::Base
  include FakeNpqQualificationsData

  get "/api/teacher-record-service/v1/qualifications/:trn" do
    content_type :json

    trn = params[:trn]
    case bearer_token
    when "token"
      quals_data.to_json
      if trn.present?
        quals_data(trn:).to_json
      else
        no_data
      end
    when "invalid-token"
      halt 401
    when "api-error"
      halt 500
    end
  end

  def bearer_token
    auth_header = request.env.fetch("HTTP_AUTHORIZATION")
    auth_header.delete_prefix("Bearer ")
  end
end