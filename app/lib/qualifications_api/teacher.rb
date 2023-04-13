module QualificationsApi
  class Teacher
    attr_reader :api_data

    def initialize(api_data)
      @api_data = Hashie::Mash.new(api_data.deep_transform_keys(&:underscore))
    end

    delegate :first_name, :last_name, :trn, to: :api_data

    def qualifications
      @qualifications = []

      if api_data.qts&.awarded&.present?
        @qualifications << Qualification.new(
          awarded_at: api_data.qts.awarded.to_date,
          certificate_url: api_data.qts.certificate_url,
          name: "Qualified teacher status (QTS)",
          type: :qts
        )
      end

      if api_data.eyts&.awarded&.present?
        @qualifications << Qualification.new(
          awarded_at: api_data.eyts&.awarded&.to_date,
          certificate_url: api_data.eyts&.certificate_url,
          name: "Early years teacher status (EYTS)",
          type: :eyts
        )
      end

      api_data
        .fetch("npq_qualifications", [])
        .each do |npq|
          @qualifications << Qualification.new(
            awarded_at: npq.awarded.to_date,
            certificate_url: npq.certificate_url,
            name: npq.type.name,
            type: npq.type.code.to_sym
          )
        end

      @qualifications << api_data
        .fetch("initial_teacher_training", [])
        .map do |itt_response|
          Qualification.new(
            awarded_at: itt_response.end_date&.to_date,
            details: itt_response,
            name: "Initial teacher training (ITT)",
            type: :itt
          )
        end

      if api_data.induction&.end_date&.present?
        @qualifications << Qualification.new(
          awarded_at: api_data.induction.end_date.to_date,
          details: api_data.induction,
          name: "Induction",
          type: :induction
        )
      end

      if api_data.mandatory_qualifications.present?
        @qualifications << api_data.mandatory_qualifications.map do |mq|
          Qualification.new(
            awarded_at: mq.awarded.to_date,
            details: mq,
            name: "Mandatory qualification (MQ): specialist teacher",
            type: :mandatory
          )
        end
      end

      @qualifications.flatten!.sort_by!(&:awarded_at).reverse!
    end
  end
end
