# frozen_string_literal: true

class QualificationSummaryComponent < ViewComponent::Base
  include ActiveModel::Model

  attr_accessor :qualification

  delegate :awarded_at,
           :certificate_type,
           :qtls_only,
           :details,
           :id,
           :itt?,
           :qts?,
           :passed_induction,
           :failed_induction,
           :set_membership_active,
           :set_membership_expired,
           :name,
           :type,
           :qts_and_qtls,
           to: :qualification

  alias_method :title, :name

  def rows
    @rows ||= build_rows.select { |row| row[:value][:text].present? }
  end

  def build_rows
    return itt_rows if itt?
    return qtls_rows if qts? && qtls_only
      
    qualification_rows = [
      { key: { text: "Awarded" }, value: { text: awarded_at&.to_fs(:long_uk) } },
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

    if qualification.status_description
      qualification_rows << {
        key: {
          text: "Status"
        },
        value: {
          text: qualification.status_description
        }
      }
    end

    if details.specialism
      qualification_rows << {
        key: {
          text: "Specialism"
        },
        value: {
          text: details.specialism
        }
      }
    end

    qualification_rows
  end

  def itt_rows
    return [] if details.end_date.blank?

    [
      {
        key: {
          text: "Qualification"
        },
        value: {
          text: details.qualification&.name
        }
      },
      {
        key: {
          text: "ITT provider"
        },
        value: {
          text: details.provider&.name
        }
      },
      {
        key: {
          text: "Training type"
        },
        value: {
          text: details.programme_type_description
        }
      },
      {
        key: {
          text: "Subjects"
        },
        value: {
          text:
            details.subjects.map { |subject| subject.name.titleize }.join(", ")
        }
      },
      {
        key: {
          text: "Start date"
        },
        value: {
          text: details.start_date&.to_date&.to_fs(:long_uk)
        }
      },
      {
        key: {
          text: "End date"
        },
        value: {
          text: details.end_date&.to_date&.to_fs(:long_uk)
        }
      },
      {
        key: {
          text: "Status"
        },
        value: {
          text: details.result&.to_s&.humanize
        }
      },
      {
        key: {
          text: "Age range"
        },
        value: {
          text: details.age_range&.description
        }
      }
    ]
  end

  def qtls_rows
    if set_membership_active
      [
        {
          key: { 
            text: "Awarded"
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
