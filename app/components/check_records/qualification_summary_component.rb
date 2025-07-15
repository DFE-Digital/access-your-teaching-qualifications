# frozen_string_literal: true

class CheckRecords::QualificationSummaryComponent < ViewComponent::Base
  include ActiveModel::Model

  attr_accessor :qualification

  delegate :awarded_at,
           :certificate_type,
           :details,
           :id,
           :induction?,
           :rtps?,
           :qtls_only,
           :set_membership_active,
           :set_membership_expired,
           :mq?,
           :name,
           :type,
           :qts?,
           :eyts?,
           :passed_induction,
           :failed_induction,
           :qts_and_qtls,
           to: :qualification

  def title
    return [name, rtps_route_type].compact.join(": ") if rtps?

    name
  end

  def rows
    @rows ||= build_rows.select { |row| row[:value][:text].present? }
  end

  def build_rows
    if rtps?
      rtps_rows
    elsif mq?
      mq_rows
    elsif induction?
      induction_rows
    elsif qts?
      qts_rows
    elsif eyts?
      eyts_rows
    else
      [
        { key: { text: "Held since" }, value: { text: awarded_at&.to_fs(:long_uk) } },
      ]
    end
  end

  def induction_rows
    if qtls_only && !passed_induction && !failed_induction?
      if set_membership_active
        return [
          { key: { text: "Induction status" }, value: { text: "Exempt" } },
          { key: { text: "Reason for exemption" },
            value: { text: details[:exemption_reasons]&.map(&:name)&.join(", ") } }
        ]
      else
        return [{ key: { text: "Induction status" }, value: { text: "No induction"} }]
      end
    end

    [
      {
        key: { text: "Induction status" },
        value: { text: description_text(details&.status) }
      },
      { key: { text: "Date completed" }, value: { text: awarded_at&.to_fs(:long_uk) } }
    ]
  end

  def rtps_rows
    [
      { key: { text: "Qualification" }, value: { text: details.degree_type&.name } },
      { key: { text: "Provider" }, value: { text: details.training_provider&.name } },
      {
        key: {
          text: "Subject"
        },
        value: {
          text: details.training_subjects&.map { |subject| subject.name.titleize }&.join(", ")
        }
      },
      {
        key: { text: "Age range" },
        value: { text: age_range_from_training_age_specialism(details.training_age_specialism) }
      },
      {
        key: {
          text: "Start date"
        },
        value: {
          text: details.training_start_date&.to_date&.to_fs(:long_uk)
        }
      },
      {
        key: {
          text: "End date"
        },
        value: {
          text: details.training_end_date&.to_date&.to_fs(:long_uk)
        }
      },
      { key: { text: "Result" }, value: { text: details.status&.to_s&.underscore&.humanize } }
    ]
  end

  def rtps_route_type
    details.route_to_professional_status_type&.name
  end

  def age_range_from_training_age_specialism(training_age_specialism)
    case training_age_specialism&.type
    when "Range"
      "#{training_age_specialism.from} to #{training_age_specialism.to} years"
    else
      # Easier to use a hash lookup for the known types
      # Rather than .underscore.humanize, especially since that tactic just results in "Key stage1"
      {
        'FoundationStage' => "Foundation stage",
        'FurtherEducation' =>  "Further education",
        'KeyStage1' =>  "Key stage 1",
        'KeyStage2' =>  "Key stage 2",
        'KeyStage3' =>  "Key stage 3",
        'KeyStage4' =>  "Key stage 4"
      }[training_age_specialism&.type]
    end
  end

  def mq_rows
    [
      { key: { text: "Specialism" }, value: { text: details.specialism } },
      { key: { text: "Held since" }, value: { text: awarded_at.to_fs(:long_uk) } }
    ]
  end

  def qts_rows
    rows = [{ key: { text: "Status" }, value: { text: qts_status_text } }]
    unless qtls_only && !set_membership_active
      rows.append( { key: { text: "Held since" }, value: { text: awarded_at&.to_fs(:long_uk) } } )
    end
    rows
  end

  def qts_status_text
    return "Qualified Teacher Status (QTS)" unless qtls_only
    return "Qualified via qualified teacher learning and skills (QTLS) status" if set_membership_active

    "No QTS"
  end

  def eyts_rows
    [{ key: { text: "Held since" }, value: { text: awarded_at&.to_fs(:long_uk) } }]
  end

  def failed_induction?
    details&.status.present? ? details&.status == "Failed" : false
  end

  def induction_required_to_complete?
    !passed_induction && !failed_induction?
  end

  def render_induction_exemption_message?
    induction? && set_membership_active && induction_required_to_complete?
  end

  def render_qts_induction_exemption_message
    qts? && qtls_only && set_membership_active && !passed_induction && !failed_induction
  end

  def render_induction_exemption_warning?
    induction? && set_membership_expired && !passed_induction && details&.status != "Failed" && details&.status != "Exempt"
  end

  def render_qtls_warning_message?
    qts? && qtls_only && set_membership_expired && !passed_induction
  end

  def description_text(status)
    status&.underscore&.humanize unless status.blank? || status == "None"
  end
end
