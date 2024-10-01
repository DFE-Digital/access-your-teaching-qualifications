# frozen_string_literal: true

require "rails_helper"

RSpec.describe CheckRecords::TeacherProfileSummaryComponent, type: :component do
  let(:teacher) { QualificationsApi::Teacher.new({}) }

  describe "rendering" do
    subject { page }

    before { render_inline(described_class.new(teacher)) }

    it { is_expected.to have_text("No QTS or EYTS") }
    it { is_expected.to have_text("No induction") }

    context "when teacher has EYPS" do
      let(:teacher) { QualificationsApi::Teacher.new({ 'eyps' => { 'awarded' => Time.current }}) }

      it { is_expected.to have_text("EYPS") }
    end
    
    context "when teacher has QTS" do
      let(:teacher) { QualificationsApi::Teacher.new({ 'qts' => { 'awarded' => Time.current }}) }

      it { is_expected.to have_text("QTS") }
    end

    context "when teacher has passed induction" do
      let(:teacher) { QualificationsApi::Teacher.new({ 'induction' => { 'status_description' => 'Pass' }}) }

      it { is_expected.to have_text("Passed induction") }
    end

    context "when teacher has failed induction" do
      let(:teacher) { QualificationsApi::Teacher.new({ 'induction' => { 'status_description' => 'Fail' }}) }

      it { is_expected.not_to have_text("Passed induction") }
    end

    context "when teacher is exempt from induction" do
      let(:teacher) { QualificationsApi::Teacher.new({ 'induction' => { 'status' => 'Exempt' }}) }

      it { is_expected.to have_text("Exempt from induction") }
    end
  end
end
