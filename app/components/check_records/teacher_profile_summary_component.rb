# frozen_string_literal: true

class CheckRecords::TeacherProfileSummaryComponent < ApplicationComponent
  attr_reader :teacher
  attr_accessor :tags

  def initialize(teacher)
    super()
    @teacher = teacher
    @tags = []
    build_tags
  end

  def build_tags
    tags << restriction_tag
    tags << teaching_status_tag
    tags << induction_tag
  end

  private

  delegate :induction_status, :no_induction?, :no_restrictions?, :no_qts_or_eyts?, :teaching_status, 
           :restriction_status, :set_membership_active?, :set_membership_expired?,
           to: :teacher

  def restriction_tag
    { message: restriction_status, colour: no_restrictions? ? "green" : "red"}
  end

  def teaching_status_tag
    { message: teaching_status, colour: teaching_status_tag_colour}
  end

  def induction_tag
    { message: induction_status, colour: no_induction? ? 'blue' : 'green'}
  end

  def teaching_status_tag_colour
    if teacher.qtls_only?
      if set_membership_active?
        return 'green'
      elsif set_membership_expired?
        return 'blue'
      end
    end
    no_qts_or_eyts? ? 'blue' : 'green'
  end
end
