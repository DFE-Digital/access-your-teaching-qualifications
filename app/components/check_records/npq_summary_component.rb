# frozen_string_literal: true

class CheckRecords::NpqSummaryComponent < ViewComponent::Base
  include ActiveModel::Model

  attr_accessor :npqs

  def rows
    @rows ||= npqs.map do |npq|
      {
        key: {
          text: key_text(npq)
        },
        value: {
          text: npq.awarded_at.to_fs(:long_uk)
        }
      }
    end
  end

  private

  def key_text(npq)
    tidied_name = npq.name.gsub(/National Professional Qualification \(NPQ\) for /, '')
    "Date NPQ for #{tidied_name} awarded"
  end
end
