# frozen_string_literal: true

class CheckRecords::TeacherProfileSummaryComponent < ApplicationComponent
  attr_reader :teacher
  attr_accessor :tags

  def initialize(teacher)
    super()
    @teacher = teacher
    @tags = build_tags
  end

  private

  def build_tags
    [
      restriction_tag,
      teaching_status_tag,
      induction_tag,
    ].compact
  end

  delegate :induction_status, :no_induction?, :no_restrictions?, :no_qts_or_eyts?, :teaching_status, 
           :restriction_status, :set_membership_active?, :set_membership_expired?, :qtls_only?, :qts_and_qtls?,
           :passed_induction?, :failed_induction?, :exempt_from_induction?,
           to: :teacher

  def restriction_tag
    { message: "Restricted", colour: "red" } unless no_restrictions?
  end

  def teaching_status_tag
    { message: teaching_status, colour: teaching_status_tag_colour}
  end

  def induction_tag
    { message: induction_tag_message, colour: no_induction? ? 'blue' : 'green'}
  end

  def induction_tag_message
    return 'Passed induction' if passed_induction?
    return 'Failed induction' if failed_induction?
    return 'Induction Exempt' if exempt_from_induction?

    'No induction'
  end

  def teaching_status_tag_colour
    if qtls_only?
      if set_membership_active?
        return 'green'
      elsif set_membership_expired?
        return 'blue'
      end
    end

    no_qts_or_eyts? ? 'blue' : 'green'
  end
end
