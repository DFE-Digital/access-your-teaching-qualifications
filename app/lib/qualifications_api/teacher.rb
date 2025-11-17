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

    QTLS_ROUTE_ID = "BE6EAF8C-92DD-4EFF-AAD3-1C89C4BEC18C".freeze

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
      @qualifications ||= [
        npq_qualifications,
        mq_qualifications,
        induction_qualification,
        qts_qualifications,
        eyts_qualifications,
        all_other_rtps_qualifications,
      ].flatten.compact
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
      api_data.alerts&.filter_map do |alert|
        Sanction.new(alert) if alert_showable?(alert)
      end
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
      api_data.qts&.holds_from.present?
    end

    def eyts_awarded?
      api_data.eyts&.holds_from.present?
    end

    def npq_awarded?
      npq_data.body["data"]["qualifications"] != []
    end

    def eyps_awarded?
      api_data.eyps&.awarded.present?
    end

    def induction_status
      return 'Passed' if passed_induction?
      return 'Failed' if failed_induction?
      return 'Exempt from induction' if exempt_from_induction?

      'No induction'
    end

    def induction_status_values
      [api_data.induction&.status, api_data.induction_status&.status]
    end

    def passed_induction?
      induction_status_values.intersect?(["Passed", "Pass"])
    end

    def failed_induction?
      induction_status_values.include?("Failed")
    end

    def exempt_from_induction?
      exempt_from_induction_via_induction_status? || exempt_from_induction_via_qts_via_qtls?
    end

    def exempt_from_induction_via_induction_status?
      induction_status_values.include?("Exempt")
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
      return false if qts_and_qtls?

      routes = api_data&.qts&.routes || []
      route_status_type_ids = routes.map do |route|
        # upcase to ensure case insensitivity
        route.route_to_professional_status_type.route_to_professional_status_type_id.upcase
      end
      route_status_type_ids.uniq == [QTLS_ROUTE_ID.upcase] # upcase to ensure case insensitivity
    end

    def no_details?
      api_data.induction.status == "None" &&
        api_data.eyps.blank? &&
        api_data.qts.blank? &&
        api_data.eyts.blank? &&
        npq_data.body["data"]["qualifications"].blank?
    end

    def render_qtls_expired_message?
      api_data.qtls_status == "Expired" && !qts_awarded?
    end

    private

    def qts_qualification
      qts_data = api_data.qts
      return if qts_data.blank? && !qtls_only?

      @qts_qualification ||= Qualification.new(
        awarded_at: qts_data&.holds_from&.to_date,
        name: "Qualified teacher status (QTS)",
        qtls_only: qtls_only?,
        qts_and_qtls: qts_and_qtls?,
        set_membership_active: set_membership_active?,
        set_membership_expired: set_membership_expired?,
        passed_induction: passed_induction?,
        failed_induction: failed_induction?,
        type: :qts,
        routes: qts_data.routes || []
      )
    end

    def qts_qualifications
      return if qts_qualification.nil?

      [
        qts_qualification,
        rtps_qualifications(type: :qts, route_ids: qts_qualification.route_ids, include_blank: true)
      ].flatten
    end

    def eyts_qualification
      eyts_data = api_data.eyts
      return if eyts_data.blank?

      @eyts_qualification ||= Qualification.new(
        awarded_at: eyts_data.holds_from&.to_date,
        name: "Early years teacher status (EYTS)",
        type: :eyts,
        routes: eyts_data.routes || []
      )
    end

    def eyts_qualifications
      return if eyts_qualification.nil?

      [
        eyts_qualification,
        rtps_qualifications(type: :eyts, route_ids: eyts_qualification.route_ids)
      ].flatten
    end

    def all_rtps_ids
      return [] if api_data.routes_to_professional_statuses.blank?

      api_data.routes_to_professional_statuses.map do |route|
        route.route_to_professional_status_type.route_to_professional_status_type_id
      end
    end

    def all_other_rtps_qualifications
      eyts_route_ids = eyts_qualification&.route_ids || []
      qts_route_ids = qts_qualification&.route_ids || []

      non_qts_eyts_route_ids = all_rtps_ids - eyts_route_ids - qts_route_ids

      rtps_qualifications(
        type: :other,
        route_ids: non_qts_eyts_route_ids,
        name: "Route to Professional Status"
      )
    end

    def npq_qualifications
      return [] if @npq_data == []

      @npq_data.body["data"]["qualifications"]
        .sort_by { |npq| npq["award_date"]&.to_date }
        .reverse
        .map do |npq|
        Qualification.new(
          awarded_at: npq["award_date"]&.to_date,
          name: NPQ_QUALIFICATION_NAME[npq["npq_type"].to_sym],
          type: npq["npq_type"]&.to_sym
        )
      end
    end

    def rtps_qualifications(type:, route_ids: [], include_blank: false, name: nil)
      return [] if api_data.routes_to_professional_statuses.blank?

      routes = api_data.routes_to_professional_statuses.select do |route|
        route_id = route.route_to_professional_status_type.route_to_professional_status_type_id

        route_ids.include?(route_id) || (include_blank && route_id.blank?)
      end

      sorted_routes = routes.sort_by { |r|
        date = r.holds_from&.to_date
        [date ? 1 : 0, date]
      }.reverse

      sorted_routes.map do |route|
        Qualification.new(
          awarded_at: route.training_end_date&.to_date,
          details: CoercedDetails.new(route),
          name: name || "Route to #{type.to_s.upcase}",
          type: :"#{type}_rtps"
        )
      end
    end

    def induction_qualification
      return [] if api_data.induction.blank?
      return [] if api_data.induction.status == "None" && !qtls_only?

      Qualification.new(
        awarded_at: api_data.induction&.completed_date&.to_date,
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

    def mq_qualifications
      mqs_data = api_data.mandatory_qualifications
      return [] if mqs_data.blank?

      sorted_mqs = mqs_data.sort_by { |mq| mq.end_date&.to_date }
                           .reverse

      sorted_mqs.map do |mq|
        Qualification.new(
          awarded_at: mq.end_date&.to_date,
          details: mq,
          name: "Mandatory qualification (MQ)",
          type: :mandatory
        )
      end
    end

    def alert_showable?(alert)
      alert.end_date.blank? && Sanction::SANCTIONS.key?(alert.alert_type.alert_type_id)
    end
  end

  class CoercedDetails < Hash
    include Hashie::Extensions::Coercion
    include Hashie::Extensions::MergeInitializer
    include Hashie::Extensions::MethodAccess

    def initialize(raw_data = {})
      super(self.class.flatten_and_mash(raw_data))
    end

    def self.flatten_and_mash(obj)
      case obj
      when Hash
        if obj.keys.map(&:to_s).sort == ["has_value", "value"]
          flatten_and_mash(obj["value"] || obj[:value])
        else
          Hashie::Mash.new(
            obj.each_with_object({}) do |(k, v), result|
              result[k.to_sym] = flatten_and_mash(v)
            end
          )
        end
      when Array
        obj.map { |v| flatten_and_mash(v) }
      else
        obj
      end
    end

    coerce_key :result, ->(value) {
      value.to_s.underscore.humanize
    }

    coerce_key :status, ->(value) {
      value.to_s.underscore.humanize
    }
  end
end
