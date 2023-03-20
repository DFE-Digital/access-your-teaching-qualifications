class NpqCertificatesController < QualificationsInterfaceController
  def show
    client = QualificationsApi::Client.new(token: session[:identity_user_token])
    send_data client.npq_certificate(params[:url]),
              name: "npq_certificate.pdf",
              content_type: "application/pdf"
  end
end
