# frozen_string_literal: true

class EytsSummaryComponent < ViewComponent::Base
  include ActiveModel::Model

  attr_accessor :qualification

  def rows
    [
      {
        key: {
          text: "Awarded"
        },
        value: {
          text: qualification.awarded_at.to_fs(:long_uk)
        }
      },
      {
        key: {
          text: "Certificate"
        },
        value: {
          text:
            link_to(
              "Download EYTS certificate",
              eyts_certificate_path,
              class: "govuk-link"
            )
        }
      }
    ]
  end

  def title
    qualification.name
  end
end
