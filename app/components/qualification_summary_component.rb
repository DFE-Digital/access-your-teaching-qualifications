# frozen_string_literal: true

class QualificationSummaryComponent < ViewComponent::Base
  include ActiveModel::Model

  attr_accessor :qualification

  delegate :awarded_at, :certificate_type, :details, :id, :itt?, :name, :type, to: :qualification

  alias_method :title, :name

  def rows
    return itt_rows if itt?

    @rows = [{ key: { text: "Awarded" }, value: { text: awarded_at.to_fs(:long_uk) } }]

    if qualification.certificate_url
      @rows << {
        key: {
          text: "Certificate"
        },
        value: {
          text:
            link_to(
              "Download #{type.to_s.upcase} certificate",
              qualifications_certificate_path(certificate_type, certificate_id: id),
              class: "govuk-link"
            )
        }
      }
    end

    if details.specialism
      @rows << { key: { text: "Specialism" }, value: { text: details.specialism } }
    end

    @rows
  end

  def itt_rows
    return [] if details.end_date.blank?

    [
      { key: { text: "Qualification" }, value: { text: details.dig(:qualification, :name) } },
      { key: { text: "ITT provider" }, value: { text: details.dig(:provider, :name) } },
      { key: { text: "Training type" }, value: { text: details.programme_type } },
      {
        key: {
          text: "Subjects"
        },
        value: {
          text: details.subjects.map { |subject| subject.name.titleize }.join(", ")
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
      { key: { text: "End date" }, value: { text: details.end_date&.to_date&.to_fs(:long_uk) } },
      { key: { text: "Status" }, value: { text: details.result&.to_s&.humanize } },
      { key: { text: "Age range" }, value: { text: details.age_range&.description } }
    ]
  end
end
