module Qualifications
  class CertificatesController < QualificationsInterfaceController
    def show
      client = QualificationsApi::Client.new(token: session[:identity_user_token])
      certificate =
        client.certificate(name: current_user.name, type: params[:id], id: params[:certificate_id])

      send_data certificate.file_data,
                filename: certificate.file_name,
                content_type: "application/pdf"
    end
  end
end
