# frozen_string_literal: true

class IttSummaryComponent < ViewComponent::Base
  include ActiveModel::Model

  attr_accessor :qualification

  def rows
    [
      {
        key: {
          text: "Qualification"
        },
        value: {
          text: qualification.qualification_name
        }
      },
      {
        key: {
          text: "ITT provider"
        },
        value: {
          text: qualification.provider_name
        }
      },
      {
        key: {
          text: "Training type"
        },
        value: {
          text: qualification.programme_type
        }
      },
      {
        key: {
          text: "Subjects"
        },
        value: {
          text: qualification.subjects.map(&:titleize).join(", ")
        }
      },
      {
        key: {
          text: "Start date"
        },
        value: {
          text: qualification.start_date.to_fs(:long_uk)
        }
      },
      {
        key: {
          text: "End date"
        },
        value: {
          text: qualification.end_date.to_fs(:long_uk)
        }
      },
      {
        key: {
          text: "Result"
        },
        value: {
          text: qualification.result.to_s.humanize
        }
      },
      { key: { text: "Age range" }, value: { text: qualification.age_range } }
    ]
  end

  def title
    qualification.name
  end
end
