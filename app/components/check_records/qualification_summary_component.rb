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
           :type,
           to: :qualification

  alias_method :title, :name

  def rows
    return itt_rows if itt?
    return mq_rows if mq?
    return induction_rows if induction?

    [{ key: { text: "Date awarded" }, value: { text: awarded_at&.to_fs(:long_uk) } }]
  end

  def induction_rows
    [
      { key: { text: "Induction status" }, value: { text: details.status&.to_s&.humanize } },
      { key: { text: "Date completed" }, value: { text: awarded_at&.to_fs(:long_uk) } }
    ]
  end

  def itt_rows
    [
      { key: { text: "Qualification" }, value: { text: details.dig(:qualification, :name) } },
      { key: { text: "ITT provider" }, value: { text: details.dig(:provider, :name) } },
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
