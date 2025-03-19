# frozen_string_literal: true

class QualificationSummaryComponent < ViewComponent::Base
  include ActiveModel::Model

  attr_accessor :qualification

  delegate :awarded_at,
           :certificate_type,
           :qtls_applicable,
           :details,
           :id,
           :itt?,
           :qts?,
           :passed_induction,
           :name,
           :type,
           to: :qualification

  alias_method :title, :name

  def rows
    return itt_rows if itt?
    if qts? && qtls_applicable
      return combined_qts_qtls_rows if !passed_induction && awarded_at.present? 
      return qtls_rows
    end

    @rows = [
      { key: { text: "Awarded" }, value: { text: awarded_at&.to_fs(:long_uk) } }
    ]

    if qualification.certificate_url
      @rows << {
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
    end

    if qualification.status_description
      @rows << {
        key: {
          text: "Status"
        },
        value: {
          text: qualification.status_description
        }
      }
    end

    if details.specialism
      @rows << {
        key: {
          text: "Specialism"
        },
        value: {
          text: details.specialism
        }
      }
    end

    @rows.select { |row| row[:value][:text].present? }
  end

  def itt_rows
    return [] if details.end_date.blank?

    @rows = [
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
    if qualification.set_membership_active
      [
        {
          key: { 
            text: "Awarded"
          }, 
          value: {
            text: "#{awarded_at&.to_fs(:long_uk)} via qualified teacher learning and skills (QTLS) status"
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
    elsif !qualification.set_membership_active
      [
        { key: { text: "No QTS" }, value: { text: awarded_at&.to_fs(:long_uk) } },
      ]
    end
  end

  def combined_qts_qtls_rows
    @rows = qtls_rows
    if !qualification.set_membership_active && qualification.certificate_url
      @rows << {
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
    end
    @rows.select { |row| row[:value][:text].present? }
  end
end
