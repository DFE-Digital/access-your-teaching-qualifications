# frozen_string_literal: true

class CheckRecords::NpqSummaryComponent < ViewComponent::Base
  include ActiveModel::Model

  attr_accessor :npqs

  def rows
    npqs.map do |npq|
      {
        key: {
          text: ["Date", npq.name, "awarded"].join(" ")
        },
        value: {
          text: npq.awarded_at.to_fs(:long_uk)
        }
      }
    end
  end
end
