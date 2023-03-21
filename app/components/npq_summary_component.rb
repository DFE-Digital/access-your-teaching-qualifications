# frozen_string_literal: true

class NpqSummaryComponent < ViewComponent::Base
  include ActiveModel::Model

  attr_accessor :qualification

  def rows
    [
      { key: { text: "Awarded" }, value: { text: qualification.awarded_at.to_fs(:long_uk) } },
      {
        key: {
          text: "Certificate"
        },
        value: {
          text:
            link_to(
              "Download #{qualification.name} certificate",
              npq_certificate_path(url: qualification.certificate_url),
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
