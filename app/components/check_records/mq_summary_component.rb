# frozen_string_literal: true

class CheckRecords::MqSummaryComponent < ViewComponent::Base
  include ActiveModel::Model

  attr_accessor :mqs

  def rows
    mqs.map do |mq|
      {
        key: {
          text: key_text(mq)
        },
        value: {
          text: mq.awarded_at.to_fs(:long_uk)
        }
      }
    end
  end

  private

  def key_text(mandatory_qualification)
    "Date #{mandatory_qualification.details.specialism.downcase} MQ awarded"
  end
end
