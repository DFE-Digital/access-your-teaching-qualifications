module QualificationsApi
  class Teacher
    attr_reader :api_data

    def initialize(api_data)
      @api_data = Hashie::Mash.new(api_data.deep_transform_keys(&:underscore))
    end

    def name
      ::NameOfPerson::PersonName.full("#{first_name} #{middle_name} #{last_name}")
    end

    delegate :date_of_birth,
             :first_name,
             :last_name,
             :middle_name,
             :sanctions,
             :trn,
             to: :api_data

    def previous_names
      return [] unless api_data.previous_names&.any?

      previous_last_names = api_data.previous_names.map(&:last_name).compact.uniq(&:downcase)
      previous_last_names.reject { |name| name.downcase == last_name.downcase }.map(&:titleize)
    end

    def qualifications
      @qualifications = []

      add_npq
      add_mandatory_qualifications
      add_induction
      add_qts
      add_itt
      add_eyts
      add_itt(qts: false)

      @qualifications.flatten!
    end

    def sanctions
      api_data.sanctions&.map { |sanction| Sanction.new(sanction) }
    end

    def qts_awarded?
      api_data.qts&.awarded.present?
    end

    def eyts_awarded?
      api_data.eyts&.awarded.present?
    end

    def eyps_awarded?
      api_data.eyps&.awarded.present?
    end

    def passed_induction?
      api_data.induction&.status_description == "Pass"
    end

    def exempt_from_induction?
      api_data.induction&.status == "Exempt"
    end

    def pending_name_change?
      api_data.pending_name_change == true
    end

    def pending_date_of_birth_change?
      api_data.pending_date_of_birth_change == true
    end

    def no_details?
      qualifications.empty? && 
        api_data.induction.blank? && 
        api_data.eyps.blank? && 
        api_data.qts.blank? && 
        api_data.eyts.blank?
    end

    private

    def add_qts
      return if api_data.qts.blank?

      @qualifications << Qualification.new(
        awarded_at: api_data.qts.awarded&.to_date,
        certificate_url: api_data.qts.certificate_url,
        name: "Qualified teacher status (QTS)",
        status_description: api_data.qts.status_description,
        type: :qts
      )
    end

    def add_eyts
      return if api_data.eyts.blank?

      @qualifications << Qualification.new(
        awarded_at: api_data.eyts.awarded&.to_date,
        certificate_url: api_data.eyts.certificate_url,
        name: "Early years teacher status (EYTS)",
        status_description: api_data.eyts.status_description,
        type: :eyts
      )
    end

    def add_npq
      api_data
        .fetch("npq_qualifications", [])
        .sort_by { |npq| npq.awarded&.to_date }
        .reverse
        .each do |npq|
          @qualifications << Qualification.new(
            awarded_at: npq.awarded&.to_date,
            certificate_url: npq.certificate_url,
            name: npq.type&.name,
            type: npq.type&.code&.to_sym
          )
        end
    end

    def add_itt(qts: true)
      all_itt_data = api_data.fetch("initial_teacher_training", [])
      eyts_itt_data, qts_itt_data = all_itt_data.partition { |itt| itt.programme_type.to_s&.starts_with?("EYITT") }
      itt_data = qts ? qts_itt_data : eyts_itt_data

      @qualifications << itt_data
        .sort_by { |itt| itt.awarded&.to_date }
        .reverse
        .map do |itt_response|
          Qualification.new(
            awarded_at: itt_response.end_date&.to_date,
            details: CoercedDetails.new(itt_response),
            name: "Initial teacher training (ITT)",
            type: :itt
          )
        end
    end

    def add_induction
      return if api_data.induction.blank?

      @qualifications << Qualification.new(
        awarded_at: api_data.induction.end_date&.to_date,
        certificate_url: api_data.induction&.certificate_url,
        details: CoercedDetails.new(api_data.induction),
        name: "Induction",
        type: :induction
      )
    end

    def add_mandatory_qualifications
      return if api_data.mandatory_qualifications.blank?

      @qualifications << api_data.mandatory_qualifications
        .sort_by { |mq| mq.awarded&.to_date }
        .reverse
        .map do |mq|
        Qualification.new(
          awarded_at: mq.awarded&.to_date,
          details: mq,
          name: "Mandatory qualification (MQ)",
          type: :mandatory
        )
      end
    end
  end

  class CoercedDetails < Hash
    include Hashie::Extensions::Coercion
    include Hashie::Extensions::MergeInitializer
    include Hashie::Extensions::MethodAccess

    coerce_key :result, ->(value) { value.underscore.humanize }
  end
end
