class QtsCertificatesController < ApplicationController
  before_action :authenticate_user!

  def show
    client = QualificationsApi::Client.new(token: session[:identity_user_token])
    send_data client.qts_certificate,
              name: "qts_certificate.pdf",
              content_type: "application/pdf"
  end
end
