module Qualifications
  class CertificatesController < QualificationsInterfaceController
    layout "certificate"

    def show
      unless render_certificate?
        redirect_to qualifications_dashboard_path,
                    alert: "Certificate not found"
      end
    end

    private

    def client
      @client ||= QualificationsApi::Client.new(token: session[:identity_user_token])
    end

    def teacher
      @teacher ||= client.teacher
    end

    def qualification
      @qualification ||= teacher.qualifications.find { |q| q.type == certificate_type.to_sym }
    end

    def render_certificate?
      return if qualification.blank?

      case certificate_type.to_sym
      when :induction
        teacher.passed_induction?
      when :qts
        teacher.qts_awarded?
      else
        qualification.awarded_at.present?
      end
    end

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
