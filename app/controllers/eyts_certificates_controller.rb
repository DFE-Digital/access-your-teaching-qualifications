class EytsCertificatesController < QualificationsInterfaceController
  def show
    client = QualificationsApi::Client.new(token: session[:identity_user_token])
    send_data client.eyts_certificate,
              name: "eyts_certificate.pdf",
              content_type: "application/pdf"
  end
end
