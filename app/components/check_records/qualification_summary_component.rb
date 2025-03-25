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
           :qtls_only,
           :set_membership_active,
           :set_membership_expired,
           :mq?,
           :name,
           :status_description,
           :type,
           :qts?,
           :passed_induction,
           :failed_induction,
           :qts_and_qtls,
           to: :qualification

  alias_method :title, :name

  def rows
    @rows = (
      if itt?
        itt_rows
      elsif mq?
        mq_rows
      elsif induction?
        induction_rows
      elsif qts?
        qts_rows
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
    if qtls_only && !passed_induction && !failed_induction?
      if set_membership_active 
        return [{ key: { text: "Induction status" }, value: { text: "Exempt"} }]
      else 
        return [{ key: { text: "Induction status" }, value: { text: "No induction"} }]
      end
    end
    [
      { 
        key: { text: "Induction status" }, 
        value: { text: description_text(details&.status) } 
      },
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

  def qts_rows
    rows = [{ key: { text: "QTS status" }, value: { text: qts_status_text } }]
    unless qtls_only && !set_membership_active
      rows.append( { key: { text: "Date awarded" }, value: { text: awarded_at&.to_fs(:long_uk) } } )
    end
    rows
  end

  def qts_status_text
    if qtls_only && !set_membership_active
      "No QTS"
    else
      qts_status_description_text
    end
  end

  def qts_status_description_text
    if qtls_only
      "Qualified via qualified teacher learning and skills (QTLS) status"
    else 
      status_description
    end
  end

  def failed_induction?
    details&.status.present? ? details&.status == "Failed" : false
  end

  def induction_required_to_complete?
    !passed_induction && !failed_induction?
  end

  def render_induction_exemption_message?
    induction? && set_membership_active && induction_required_to_complete?
  end

  def render_qts_induction_exemption_message
    qts? && qtls_only && set_membership_active && !passed_induction && !failed_induction
  end

  def render_induction_exemption_warning?
    induction? && set_membership_expired && !passed_induction && details&.status != "Failed"
  end

  def render_qtls_warning_message?
    qts? && qtls_only && set_membership_expired && !passed_induction
  end

  def description_text(status)
    status&.underscore&.humanize unless status.blank? || status == "None"
  end
end
