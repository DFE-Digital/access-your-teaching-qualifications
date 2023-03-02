class FakeQualificationsApi < Sinatra::Base
  get "/v3/teacher" do
    content_type :json

    case bearer_token
    when "token"
      {
        trn: "3000299",
        firstName: "Terry",
        lastName: "Walsh",
        qtsDate: "2023-02-27"
      }.to_json
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
