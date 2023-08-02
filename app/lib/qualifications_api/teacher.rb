module QualificationsApi
  class Teacher
    attr_reader :api_data

    def initialize(api_data)
      @api_data = Hashie::Mash.new(api_data.deep_transform_keys(&:underscore))
    end

    def name
      ::NameOfPerson::PersonName.full("#{first_name} #{last_name}")
    end

    delegate :date_of_birth,
             :first_name,
             :last_name,
             :middle_name,
             :trn,
             to: :api_data

    def qualifications
      @qualifications = []

      add_eyts
      add_induction
      add_itt
      add_mandatory_qualifications
      add_npq
      add_qts
      add_higher_education_qualifications

      @qualifications
        .flatten!
        .sort_by! { |qualification| qualification.awarded_at || Date.new }
        .reverse!
    end

    private

    def add_qts
      return if api_data.qts.blank?

      @qualifications << Qualification.new(
        awarded_at: api_data.qts.awarded&.to_date,
        certificate_url: api_data.qts.certificate_url,
        name: "Qualified teacher status (QTS)",
        type: :qts
      )
    end

    def add_eyts
      return if api_data.eyts.blank?

      @qualifications << Qualification.new(
        awarded_at: api_data.eyts.awarded&.to_date,
        certificate_url: api_data.eyts.certificate_url,
        name: "Early years teacher status (EYTS)",
        type: :eyts
      )
    end

    def add_npq
      api_data
        .fetch("npq_qualifications", [])
        .each do |npq|
          @qualifications << Qualification.new(
            awarded_at: npq.awarded&.to_date,
            certificate_url: npq.certificate_url,
            name: npq.type&.name,
            type: npq.type&.code&.to_sym
          )
        end
    end

    def add_itt
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
    end

    def add_induction
      return if api_data.induction.blank?

      @qualifications << Qualification.new(
        awarded_at: api_data.induction.end_date&.to_date,
        certificate_url: api_data.induction&.certificate_url,
        details: api_data.induction,
        name: "Induction",
        type: :induction
      )
    end

    def add_mandatory_qualifications
      return if api_data.mandatory_qualifications.blank?

      @qualifications << api_data.mandatory_qualifications.map do |mq|
        Qualification.new(
          awarded_at: mq.awarded&.to_date,
          details: mq,
          name: "Mandatory qualification (MQ)",
          type: :mandatory
        )
      end
    end

    def add_higher_education_qualifications
      return if api_data.higher_education_qualifications.blank?

      @qualifications << api_data.higher_education_qualifications.map do |heq|
        Qualification.new(
          awarded_at: heq.awarded&.to_date,
          details: heq,
          name: heq.name,
          type: :higher_education
        )
      end
    end
  end
end
