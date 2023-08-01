# frozen_string_literal: true

class InductionSummaryComponent < ViewComponent::Base
  include ActiveModel::Model

  attr_accessor :qualification

  delegate :awarded_at, :certificate_type, :details, :name, to: :qualification

  def detail_classes
    "app__induction-details"
  end

  def list_classes
    "app__induction-details-list"
  end

  def history
    details
      .periods
      .map do |period|
        [
          {
            key: {
              text: "Appropriate body"
            },
            value: {
              text: period.appropriate_body.name
            }
          },
          {
            key: {
              text: "Start date"
            },
            value: {
              text: period.start_date.to_date.to_fs(:long_uk)
            }
          },
          {
            key: {
              text: "End date"
            },
            value: {
              text: period.end_date&.to_date&.to_fs(:long_uk)
            }
          },
          { key: { text: "Number of terms" }, value: { text: period.terms } }
        ]
      end
      .flatten
  end

  def rows
    @rows = [
      {
        key: {
          text: "Status"
        },
        value: {
          text: details.status.to_s.humanize
        }
      },
      {
        key: {
          text: "Completed"
        },
        value: {
          text: awarded_at&.to_fs(:long_uk)
        }
      }
    ]

    if details.certificate_url.present?
      @rows << {
        key: {
          text: "Certificate"
        },
        value: {
          text:
            link_to(
              "Download Induction certificate",
              qualifications_certificate_path(
                certificate_type,
                certificate_url: details.certificate_url
              ),
              class: "govuk-link"
            )
        }
      }
    end
    @rows
  end

  def title
    name
  end
end
