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
    if teacher.qts_awarded?
      tags.append "QTS"
    end

    if teacher.passed_induction?
      tags.append "Passed induction"
    end

    if no_restrictions?
      tags.append "No restrictions"
    end
  end

  private

  def no_restrictions?
    return true if sanctions.blank?
    return false if sanctions.any?(&:possible_match_on_childrens_barred_list?)
    return true if sanctions.all?(&:guilty_but_not_prohibited?)
    false
  end
end
