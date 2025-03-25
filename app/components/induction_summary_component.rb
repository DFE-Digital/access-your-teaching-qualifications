# frozen_string_literal: true

class InductionSummaryComponent < ViewComponent::Base
  include ActiveModel::Model

  attr_accessor :qualification

  delegate :awarded_at, :type, :details, :name, :qtls_only, :set_membership_active, 
  :set_membership_expired, :qts_and_qtls, :passed_induction, to: :qualification

  def detail_classes
    "app__induction-details"
  end

  def list_classes
    "app__induction-details-list"
  end

  def history
    details
      .periods
      .map do |period|
        [
          {
            key: {
              text: "Appropriate body"
            },
            value: {
              text: period&.appropriate_body&.name
            }
          },
          {
            key: {
              text: "Start date"
            },
            value: {
              text: period.start_date&.to_date&.to_fs(:long_uk)
            }
          },
          {
            key: {
              text: "End date"
            },
            value: {
              text: period.end_date&.to_date&.to_fs(:long_uk)
            }
          },
          { key: { text: "Number of terms" }, value: { text: period.terms } }
        ]
      end
      .flatten
      .select { |row| row[:value][:text].present? }
  end

  def rows
    if qtls_only && !passed_induction && details&.status != "Failed"
      @rows = qtls_rows
    else
      @rows = [
        {
          key: {
            text: "Status"
          },
          value: {
            text: description_text(details&.status)
          } ,
        },
        {
          key: {
            text: "Completed"
          },
          value: {
            text: awarded_at&.to_fs(:long_uk)
          }
        }
      ]

      if details.status == "Passed"
        @rows << {
          key: {
            text: "Certificate"
          },
          value: {
            text:
              link_to(
                "Download Induction certificate",
                qualifications_certificate_path(:induction, format: :pdf),
                class: "govuk-link"
              )
          }
        }
      end
    end
    @rows.select { |row| row[:value][:text].present? }
  end

  def title
    name
  end

  def qtls_rows
    if set_membership_active
      [
        {
          key: {
            text: "Status"
          },
          value: {
            text: "Exempt"
          } ,
        }
      ]
    elsif !set_membership_active
      [
        {
          key: {
            text: "Status"
          },
          value: {
            text: "No induction"
          } ,
        }
      ]
    end 
  end

  def render_induction_exemption_reminder?
    set_membership_active && !passed_induction && details&.status != "Failed"
  end

  def render_induction_exemption_warning?
    set_membership_expired && !passed_induction && details&.status != "Failed"
  end

  def description_text(status)
    status&.underscore&.humanize unless status.blank? || status == "None"
  end
end
