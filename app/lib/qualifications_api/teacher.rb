module QualificationsApi
  class Teacher
    attr_reader :api_data, :npq_data

    NPQ_QUALIFICATION_NAME = {
      NPQEL: "National Professional Qualification (NPQ) for Executive Leadership",
      NPQLTD: "National Professional Qualification (NPQ) for Leading Teacher Development",
      NPQLT: "National Professional Qualification (NPQ) for Leading Teaching",
      NPQH:  "National Professional Qualification (NPQ) for Headship",
      NPQML: "National Professional Qualification (NPQ) for Middle Leadership",
      NPQLL: "National Professional Qualification (NPQ) for Leading Literacy",
      NPQEYL: "National Professional Qualification (NPQ) for Early Years Leadership",
      NPQSL: "National Professional Qualification (NPQ) for Senior Leadership",
      NPQLBC: "National Professional Qualification (NPQ) for Leading Behaviour and Culture",
      NPQLPM: "National Professional Qualification (NPQ) for Leading Primary and Mathematics",
      NPQSENCO: "National Professional Qualification (NPQ) for Special Educational Needs Co-ordinators"
    }.freeze

    def initialize(api_data)
      @api_data = Hashie::Mash.new(api_data.deep_transform_keys(&:underscore))
      # This should be moved elsewhere after the integration is working
      @npq_data = NpqQualificationsApi::GetQualificationsForTeacher.new(trn: @api_data.trn).call
    end

    def name
      ::NameOfPerson::PersonName.full("#{first_name} #{middle_name} #{last_name}")
    end

    delegate :date_of_birth,
             :first_name,
             :last_name,
             :middle_name,
             :alerts,
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

    def restriction_status
      return 'No restrictions' if no_restrictions?

      'Restriction'
    end

    def no_restrictions?
      return true if sanctions.blank? || 
      sanctions.all?(&:guilty_but_not_prohibited?) || 
        sanctions.map(&:title).join.blank?
      false
    end

    def sanctions
      api_data.alerts&.map { |alert| Sanction.new(alert) }
    end

    def teaching_status
      if qtls_only?
        return 'QTS via QTLS' if set_membership_active?
        return 'No QTS' if set_membership_expired?
      end
      return 'QTS' if qts_awarded?
      return 'EYTS' if eyts_awarded?
      return 'EYPS' if eyps_awarded?

      'No QTS or EYTS'
    end

    def no_qts_or_eyts?
      !qts_awarded? && !eyts_awarded? && !eyps_awarded?
    end

    def qtls_awarded?
      api_data.qtls_status.present?
    end

    def set_membership_active?
      api_data.qtls_status == "Active"
    end

    def set_membership_expired?
      api_data.qtls_status == "Expired"
    end

    def qts_awarded?
      api_data.qts&.awarded.present?
    end

    def eyts_awarded?
      api_data.eyts&.awarded.present?
    end

    def npq_awarded?
      npq_data.body["data"]["qualifications"] != []
    end

    def eyps_awarded?
      api_data.eyps&.awarded.present?
    end

    def induction_status
    return 'Passed' if passed_induction?
    if exempt_from_induction_via_induction_status? || exempt_from_induction_via_qts_via_qtls?
      return 'Exempt from induction' 
    end
    'No induction'
    end

    def passed_induction?
      api_data.induction&.status == "Passed" || api_data.induction_status&.status == "Passed"
    end

    def failed_induction?
      api_data.induction&.status == "Failed" || api_data.induction_status&.status == "Failed"
    end

    def exempt_from_induction_via_induction_status?
      api_data.induction&.status == "Exempt" || api_data.induction_status&.status == "Exempt"
    end

    def exempt_from_induction_via_qts_via_qtls?
      !passed_induction? && set_membership_active? 
    end

    def no_induction?
      !passed_induction? && exempt_from_induction_via_induction_status?
    end

    def qts_and_qtls?
      api_data.qts&.awarded_or_approved_count&. > 1
    end

    def pending_name_change?
      api_data.pending_name_change == true
    end

    def pending_date_of_birth_change?
      api_data.pending_date_of_birth_change == true
    end

    def qtls_only?
      !qts_and_qtls? && api_data&.qts&.status_description == "Qualified Teacher Learning and Skills status"
    end

    def no_details?
        api_data.induction.status == "None" && 
        api_data.eyps.blank? && 
        api_data.qts.blank? && 
        api_data.eyts.blank? &&
        npq_data.body["data"]["qualifications"].blank?
    end

    private

    def add_qts
      return if api_data.qts.blank? && !qtls_only?

      @qualifications << Qualification.new(
        awarded_at: api_data.qts&.awarded&.to_date,
        name: "Qualified teacher status (QTS)",
        qtls_only: qtls_only?,
        qts_and_qtls: qts_and_qtls?,
        set_membership_active: set_membership_active?,
        set_membership_expired: set_membership_expired?,
        status_description: api_data.qts&.status_description,
        passed_induction: passed_induction?,
        failed_induction: failed_induction?,
        type: :qts
      )
    end

    def add_eyts
      return if api_data.eyts.blank?

      @qualifications << Qualification.new(
        awarded_at: api_data.eyts.awarded&.to_date,
        name: "Early years teacher status (EYTS)",
        status_description: api_data.eyts.status_description,
        type: :eyts
      )
    end

    def add_npq
      unless @npq_data == []
        @npq_data.body["data"]["qualifications"]
          .sort_by { |npq| npq["award_date"]&.to_date }
          .reverse
          .each do |npq|
            @qualifications << Qualification.new(
              awarded_at: npq["award_date"]&.to_date,
              name: NPQ_QUALIFICATION_NAME[npq["npq_type"].to_sym],
              type: npq["npq_type"]&.to_sym
            )
        end
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
      return if api_data.induction.status == "None" && !qtls_only?

      @qualifications << Qualification.new(
        awarded_at: api_data.induction&.end_date&.to_date,
        details: CoercedDetails.new(api_data.induction),
        qtls_only: qtls_only?,
        qts_and_qtls: qts_and_qtls?,
        set_membership_active: set_membership_active?,
        set_membership_expired: set_membership_expired?,
        passed_induction: passed_induction?, 
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
