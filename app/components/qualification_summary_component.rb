# frozen_string_literal: true

class QualificationSummaryComponent < ApplicationComponent
  include ActiveModel::Model

  attr_accessor :qualification

  delegate :awarded_at,
           :certificate_type,
           :qtls_only,
           :details,
           :id,
           :rtps?,
           :qts?,
           :eyts?,
           :passed_induction,
           :failed_induction,
           :set_membership_active,
           :set_membership_expired,
           :name,
           :type,
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
    return rtps_rows if rtps?
    return qtls_rows if qts? && qtls_only

    qualification_rows
  end

  def qualification_rows
    [
      { key: { text: "Held since" }, value: { text: awarded_at&.to_fs(:long_uk) } },
      type_supports_certificates? ? certificate_rows : nil,
      details.specialism.present? ? specialism_rows : nil,
    ].flatten.compact
  end

  def certificate_rows
    [
      {
        key: {
          text: "Certificate"
        },
        value: {
          text:
            link_to(
              "Download #{type.to_s.upcase} certificate",
              qualifications_certificate_path(type, format: :pdf),
              class: "govuk-link"
            )
        }
      }
    ]
  end

  def type_supports_certificates?
    type != :mandatory
  end

  def specialism_rows
    [
      {
        key: {
          text: "Specialism"
        },
        value: {
          text: details.specialism
        }
      }
    ]
  end

  def rtps_rows
    return [] if details.training_end_date.blank?

    [
      {
        key: {
          text: "Route Type"
        },
        value: {
          text: rtps_route_type
        }
      },
      {
        key: {
          text: "Qualification"
        },
        value: {
          text: details.degree_type&.name
        }
      },
      {
        key: {
          text: "Provider"
        },
        value: {
          text: details.training_provider&.name
        }
      },
      {
        key: {
          text: "Subjects"
        },
        value: {
          text: details.training_subjects&.map { |subject| subject.name.titleize }&.join(", ")
        }
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
      {
        key: {
          text: "Status"
        },
        value: {
          text: details.status&.to_s&.underscore&.humanize
        }
      },
      {
        key: {
          text: "Age range"
        },
        value: {
          text: age_range_from_training_age_specialism(details.training_age_specialism)
        }
      }
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

  def qtls_rows
    if set_membership_active
      [
        {
          key: {
            text: "Held since"
          },
          value: {
            text: qtls_awarded_at_text
          }
        },
        {
          key: {
            text: "Certificate"
          },
          value: {
            text:
              link_to(
                "Download #{type.to_s.upcase} certificate",
                qualifications_certificate_path(type, format: :pdf),
                class: "govuk-link"
              )
          }
        }
      ]
    elsif !set_membership_active
      [
        { key: { text: "Status" }, value: { text: "No QTS" } },
      ]
    end
  end

  def qtls_awarded_at_text
    if set_membership_active
      "#{awarded_at&.to_fs(:long_uk)} via qualified teacher learning and skills (QTLS) status"
    else
      awarded_at&.to_fs(:long_uk).to_s
    end
  end

  def render_qts_induction_exemption_message?
    qts? && qtls_only && set_membership_active && !passed_induction && !failed_induction
  end

  def render_qtls_warning_message?
    qts? && qtls_only && set_membership_expired && !passed_induction
  end
end
