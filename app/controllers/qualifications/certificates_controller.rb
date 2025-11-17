module Qualifications
  class CertificatesController < QualificationsInterfaceController
    layout "certificate"

    def show
      unless render_certificate?
        redirect_to qualifications_dashboard_path,
                    alert: "Certificate not found"
        return
      end
      Rails.logger.debug @qualification.certificate_type.downcase
      html = render_to_string(template: "qualifications/certificates/_#{@qualification.certificate_type.downcase}",
                              formats: [:html],
                              locals: { teacher: @teacher, qualification: @qualification },
                              layout: "layouts/certificate")
      grover = Grover.new(html, format: 'A4', display_url: ENV["HOSTING_DOMAIN"])
      pdf = grover.to_pdf
      send_data pdf, filename: "#{@teacher.name}_#{@qualification.type.downcase}_certificate.pdf", 
type: 'application/pdf', disposition: 'attachment'
    end

    private

    def client
      token = if FeatureFlags::FeatureFlag.active?(:one_login)
        :onelogin_user_token
      else
        :identity_user_token
      end
      @client ||= QualificationsApi::Client.new(token: session[token])
    end

    def teacher
      @teacher ||= client.teacher
    end

    def qualification
      @qualification ||= teacher.qualifications.find { |q| q.type == certificate_type.to_sym }
    end

    def render_certificate?
      return if qualification.blank?

      case qualification.type.to_sym
      when :induction
        teacher.passed_induction?
      when :qts
        teacher.qts_awarded? || teacher.qtls_only?
      when :eyts
        teacher.eyts_awarded?
      when :NPQEL,:NPQLTD,:NPQLT,:NPQH,:NPQML,:NPQLL,:NPQEYL,:NPQSL,:NPQLBC,:NPQSENCO, :NPQLPM
        teacher.npq_awarded?
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
