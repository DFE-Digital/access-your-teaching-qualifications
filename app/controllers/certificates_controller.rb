class CertificatesController < QualificationsInterfaceController
  def show
    client = QualificationsApi::Client.new(token: session[:identity_user_token])
    send_data client.certificate(
                type: params[:id],
                id: params[:certificate_id]
              ),
              name: "#{params[:type]}_certificate.pdf",
              content_type: "application/pdf"
  end
end
