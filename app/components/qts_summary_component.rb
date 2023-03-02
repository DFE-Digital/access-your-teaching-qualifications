# frozen_string_literal: true

class QtsSummaryComponent < ViewComponent::Base
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
      }
    ]
  end

  def title
    qualification.name
  end
end
