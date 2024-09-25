# frozen_string_literal: true

class CheckRecords::QualificationSummaryComponent < ViewComponent::Base
  include ActiveModel::Model

  attr_accessor :qualification

  delegate :awarded_at,
           :certificate_type,
           :details,
           :id,
           :induction?,
           :itt?,
           :mq?,
           :name,
           :status_description,
           :type,
           to: :qualification

  alias_method :title, :name

  def rows
    @rows = (
      if itt?
        itt_rows
      elsif mq?
        mq_rows
      elsif induction?
        induction_rows if induction?
      else
        [
          { key: { text: "Date awarded" }, value: { text: awarded_at&.to_fs(:long_uk) } },
          { key: { text: "Status" }, value: { text: status_description } },
        ]
      end
    )
    @rows.select { |row| row[:value][:text].present? }
  end

  def induction_rows
    [
      { key: { text: "Induction status" }, value: { text: details.status_description } },
      { key: { text: "Date completed" }, value: { text: awarded_at&.to_fs(:long_uk) } }
    ]
  end

  def itt_rows
    [
      { key: { text: "Qualification" }, value: { text: details.qualification&.name } },
      { key: { text: "ITT provider" }, value: { text: details.provider&.name } },
      { key: { text: "Programme type" }, value: { text: details.programme_type_description } },
      {
        key: {
          text: "Subject"
        },
        value: {
          text: details.subjects.map { |subject| subject.name.titleize }.join(", ")
        }
      },
      { key: { text: "Age range" }, value: { text: details.age_range&.description } },
      {
        key: {
          text: "Course start date"
        },
        value: {
          text: details.start_date&.to_date&.to_fs(:long_uk)
        }
      },
      {
        key: {
          text: "Course end date"
        },
        value: {
          text: details.end_date&.to_date&.to_fs(:long_uk)
        }
      },
      { key: { text: "Course result" }, value: { text: details.result&.to_s&.humanize } }
    ]
  end

  def mq_rows
    [
      { key: { text: "Specialism" }, value: { text: details.specialism } },
      { key: { text: "Date awarded" }, value: { text: awarded_at.to_fs(:long_uk) } }
    ]
  end
end
