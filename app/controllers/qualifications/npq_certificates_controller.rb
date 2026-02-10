module Qualifications
  class NpqCertificatesController < QualificationsInterfaceController
    def show
      client = QualificationsApi::Client.new(token: current_session.user_token)
      send_data client.npq_certificate(params[:url]),
                name: "npq_certificate.pdf",
                content_type: "application/pdf"
    end
  end
end
