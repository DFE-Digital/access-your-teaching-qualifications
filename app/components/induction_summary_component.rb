# frozen_string_literal: true

class InductionSummaryComponent < ViewComponent::Base
  include ActiveModel::Model

  attr_accessor :qualification

  def detail_classes
    "app__induction-details"
  end

  def list_classes
    "app__induction-details-list"
  end

  def history
    [
      {
        key: {
          text: "Appropriate body"
        },
        value: {
          text: "Westminster School"
        }
      },
      {
        key: {
          text: "Start date"
        },
        value: {
          text: Date.new(2014, 1, 14).to_fs(:long_uk)
        }
      },
      {
        key: {
          text: "End date"
        },
        value: {
          text: Date.new(2015, 10, 1).to_fs(:long_uk)
        }
      },
      { key: { text: "Number of terms" }, value: { text: 3 } }
    ]
  end

  def rows
    [
      {
        key: {
          text: "Status"
        },
        value: {
          text: qualification.status.to_s.humanize
        }
      },
      {
        key: {
          text: "Completed"
        },
        value: {
          text: qualification.completed_at.to_fs(:long_uk)
        }
      }
    ]
  end

  def title
    qualification.name
  end
end
