# frozen_string_literal: true

class CheckRecords::TeacherProfileSummaryComponent < ViewComponent::Base
  attr_reader :teacher, :sanctions
  attr_accessor :tags

  def initialize(teacher)
    super
    @teacher = teacher
    @sanctions = teacher.sanctions
    @tags = []
    build_tags
  end

  def build_tags
    append_restriction_tag
    append_teaching_status_tag
    append_induction_tag
  end

  private

  def append_restriction_tag
    tags << if no_restrictions?
      { message: 'No restrictions', colour: 'green'}
    elsif possible_restriction?
      { message: 'Possible restrictions', colour: 'blue'}
    else
      { message: 'Restriction', colour: 'red'}
    end
  end

  def append_teaching_status_tag
    tags << if teacher.qts_awarded?
      { message: 'QTS', colour: 'green'}
    elsif teacher.eyts_awarded?
      { message: 'EYTS', colour: 'green'}
    elsif teacher.eyps_awarded?
      { message: 'EYPS', colour: 'green'}
    else
      { message: 'No QTS or EYTS', colour: 'blue'}
    end
  end

  def append_induction_tag
    tags << if teacher.passed_induction?
      { message: 'Passed induction', colour: 'green'}
    elsif teacher.exempt_from_induction?
      { message: 'Exempt from induction', colour: 'green'}
    else
      { message: 'No induction', colour: 'blue'}
    end
  end

  def no_restrictions?
    return true if sanctions.blank?
    return false if sanctions.any?(&:possible_match_on_childrens_barred_list?)
    return true if sanctions.all?(&:guilty_but_not_prohibited?)
    false
  end

  def possible_restriction?
    true if sanctions.any?(&:possible_match_on_childrens_barred_list?)
  end
end
