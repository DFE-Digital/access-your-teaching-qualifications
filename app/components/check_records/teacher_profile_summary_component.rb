# frozen_string_literal: true

class CheckRecords::TeacherProfileSummaryComponent < ViewComponent::Base
  attr_reader :teacher
  attr_accessor :tags

  def initialize(teacher)
    super
    @teacher = teacher
    @tags = []
    build_tags
  end

  def build_tags
    append_teaching_status_tag
    append_induction_tag
  end

  private

  delegate :no_restrictions?, :possible_restrictions?, to: :teacher

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
end
