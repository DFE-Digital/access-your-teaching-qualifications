# frozen_string_literal: true

class CheckRecords::MqSummaryComponent < ApplicationComponent
  include ActiveModel::Model

  attr_accessor :mqs

  def rows
    @rows ||= mqs.flat_map do |mandatory_qualification|
      [
        {
          key: {
            text: "MQ Specialism"
          },
          value: {
            text: mandatory_qualification.details.specialism.humanize
          }
        },
        {
          key: {
            text: "Date Awarded",
          },
          value: {
            text: mandatory_qualification.awarded_at&.to_fs(:long_uk)
          }
        }
      ]
    end
  end
end
