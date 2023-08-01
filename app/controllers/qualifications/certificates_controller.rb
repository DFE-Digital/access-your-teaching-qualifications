module Qualifications
  class CertificatesController < QualificationsInterfaceController
    def show
      client =
        QualificationsApi::Client.new(token: session[:identity_user_token])
      certificate =
        client.certificate(
          name: current_user.name,
          type: certificate_type,
          id: params[:certificate_id]
        )

      if certificate
        send_data certificate.file_data,
                  filename: certificate.file_name,
                  content_type: "application/pdf"
      else
        redirect_to qualifications_dashboard_path,
                    alert: "Certificate not found"
      end
    end

    private

    def certificate_type
      if params[:id].to_sym.in? QualificationsApi::Certificate::VALID_TYPES
        params[:id]
      else
        raise UnrecognisedCertificateTypeError
      end
    end

    class UnrecognisedCertificateTypeError < StandardError
    end
  end
end
