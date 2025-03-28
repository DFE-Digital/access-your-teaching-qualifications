# frozen_string_literal: true

require "rails_helper"

RSpec.describe CheckRecords::TeacherProfileSummaryComponent, type: :component, test: :with_fake_quals_api do
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
      let(:teacher) do QualificationsApi::Teacher.new(
        { 
          'qts' => { 
              'awarded' => Time.current,
              'qtls_applicable' => false,
              'set_membership_active' => false,
              'passed_induction' => true
          }
        }
        ) 
      end

      it { is_expected.to have_text("QTS") }
    end

    context "when teacher has QTS via QTLS" do
      let(:teacher) do QualificationsApi::Teacher.new(
        { 
          'qts' => { 
              'awarded' => Time.current,
          },
          'qtlsStatus' => 'Active'
        }
        ) 
      end
      it { is_expected.to have_text("QTS via QTLS") }
    end

    context "when teacher has passed induction" do
      let(:teacher) do QualificationsApi::Teacher.new(
        { 
          'induction' => { 
              'status' => "Pass",
              },
          'qtlsStatus' => 'None'
        }
        ) 
      end

      it { is_expected.to have_text("Passed induction") }
    end

    context "when teacher has failed induction" do
      let(:teacher) do QualificationsApi::Teacher.new(
        { 
          'induction' => { 
              'status' => "Fail",
              },
          'qtlsStatus' => 'None'
        }
        ) 
      end

      it { is_expected.not_to have_text("Passed induction") }
    end

    context "when teacher is exempt from induction" do
      let(:teacher) { QualificationsApi::Teacher.new({ 'induction' => { 'status' => 'Exempt' }}) }

      it { is_expected.to have_text("Exempt from induction") }
    end

    context "when teacher does not have QTS is exempt from induction via QTLS" do
      let(:teacher) do QualificationsApi::Teacher.new(
        { 
          'qts' => {},
          'induction' => { 
              'status' => "Fail",
          },
          'qtlsStatus' => 'Active'
        }
        ) 
      end

      it { is_expected.to have_text("Exempt from induction") }
      it { is_expected.to have_text("QTS via QTLS")}
    end

    context "when teacher does not have QTS is exempt from induction via QTLS and SET membership expires" do
      let(:teacher) do QualificationsApi::Teacher.new(
        { 
          'qts' => {},
          'induction' => { 
              'status' => "Fail",
              },
          'qtlsStatus' => 'Expired'
        }
        ) 
      end

      it { is_expected.to have_text("No induction") }
      it { is_expected.to have_text("No QTS") }
    end

    context "when teacher has QTS but not completed induction and has QTLS" do
      let(:teacher) do QualificationsApi::Teacher.new(
        { 
          'qts' => {},
          'induction' => { 
              'status' => "Fail",
              },
          'qtlsStatus' => 'Active'
        }
        ) 
      end

      it { is_expected.to have_text("Exempt from induction") }
      it { is_expected.to have_text("QTS") }
    end
  end
end
