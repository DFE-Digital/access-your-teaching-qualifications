# frozen_string_literal: true

require "rails_helper"

RSpec.describe CheckRecords::TeacherProfileSummaryComponent, type: :component do
  let(:teacher) { QualificationsApi::Teacher.new({}) }

  describe "rendering" do
    describe "teaching statuses" do
      context "teacher#qts_awarded? is true" do
        before { allow(teacher).to receive(:qts_awarded?).and_return(true) }

        it "adds the QTS tag" do
          render_inline described_class.new(teacher)

          expect(page).to have_text("QTS")
        end
      end

      context "teacher#qts_awarded? is false" do
        before { allow(teacher).to receive(:qts_awarded?).and_return(false) }

        it "does not add the QTS tag" do
          render_inline described_class.new(teacher)

          expect(page).to have_text("No QTS or EYTS")
        end
      end

      context "teacher#eyts_awarded? is true" do
        before { allow(teacher).to receive(:eyts_awarded?).and_return(true) }

        it "adds the EYTS tag" do
          render_inline described_class.new(teacher)

          expect(page).to have_text("EYTS")
        end
      end

      context "teacher#eyts_awarded? is false" do
        before { allow(teacher).to receive(:eyts_awarded?).and_return(false) }

        it "does not add the EYTS tag" do
          render_inline described_class.new(teacher)

          expect(page).to have_text("No QTS or EYTS")
        end
      end

      context "teacher#eyps_awarded? is true" do
        before { allow(teacher).to receive(:eyps_awarded?).and_return(true) }

        it "adds the QTS tag" do
          render_inline described_class.new(teacher)

          expect(page).to have_text("EYPS")
        end
      end

      context "teacher#eyps_awarded? is false" do
        before { allow(teacher).to receive(:eyps_awarded?).and_return(false) }

        it "does not add the QTS tag" do
          render_inline described_class.new(teacher)

          expect(page).not_to have_text("EYPS")
        end
      end

      context "no qts or etys" do
        before { allow(teacher).to receive(:eyts_awarded?).and_return(false) }
        before { allow(teacher).to receive(:eyps_awarded?).and_return(false) }
        before { allow(teacher).to receive(:qts_awarded?).and_return(false) }


        it "adds the No QTS or EYTS tag" do
          render_inline described_class.new(teacher)

          expect(page).to have_text("No QTS or EYTS")
        end
      end
    end

    describe 'induction statuses' do

      context "teacher#passed_induction? is true" do
        before { allow(teacher).to receive(:passed_induction?).and_return(true) }

        it "adds the Passed induction tag" do
          render_inline described_class.new(teacher)

          expect(page).to have_text("Passed induction")
        end
      end

      context "teacher#passed_induction? is false" do
        before { allow(teacher).to receive(:passed_induction?).and_return(false) }

        it "does not add the Passed induction tag" do
          render_inline described_class.new(teacher)

          expect(page).not_to have_text("Passed induction")
        end
      end

      context "teacher#exempt_from_induction? is true" do
        before { allow(teacher).to receive(:exempt_from_induction?).and_return(true) }

        it "adds the Passed induction tag" do
          render_inline described_class.new(teacher)

          expect(page).to have_text("Exempt from induction")
        end
      end

      context "teacher#exempt_from_induction? is false" do
        before { allow(teacher).to receive(:exempt_from_induction?).and_return(false) }

        it "does not add the Passed induction tag" do
          render_inline described_class.new(teacher)

          expect(page).not_to have_text("Exempt from induction")
        end
      end

      context "teacher#exempt_from_induction? and teacher#passed_induction? is false" do
        before { allow(teacher).to receive(:exempt_from_induction?).and_return(false) }
        before { allow(teacher).to receive(:passed_induction?).and_return(false) }

        it "does not add the Passed induction tag" do
          render_inline described_class.new(teacher)

          expect(page).to have_text("No induction")
        end
      end
    end

    describe 'restrictions statuses' do
      describe "No restrictions tag" do
        context "teacher#sanctions is blank" do
          before { allow(teacher).to receive(:sanctions).and_return nil }

          it "adds the No restrictions tag" do
            render_inline described_class.new(teacher)

            expect(page).to have_text("No restrictions")
          end
        end

        context "teacher#sanctions returns a possible match on the childrens barred list " do
          before do
            allow(teacher).to receive(:sanctions).and_return(
              [
                instance_double(Sanction, possible_match_on_childrens_barred_list?: true),
                instance_double(Sanction, possible_match_on_childrens_barred_list?: false)
              ]
            )
          end

          it "does not add the No restrictions tag" do
            render_inline described_class.new(teacher)

            expect(page).not_to have_text("No restrictions")
            expect(page).to have_text("Possible restriction")
          end
        end

        context "teacher#sanctions returns guilty but not prohibited sanctions only" do
          before do
            allow(teacher).to receive(:sanctions).and_return(
              [
                instance_double(
                  Sanction, possible_match_on_childrens_barred_list?: false, guilty_but_not_prohibited?: true
                ),
                instance_double(
                  Sanction, possible_match_on_childrens_barred_list?: false, guilty_but_not_prohibited?: true
                )
              ]
            )
          end

          it "adds the No restrictions tag" do
            render_inline described_class.new(teacher)

            expect(page).to have_text("No restrictions")
          end
        end

        context "teacher#sanctions returns any other kind of sanction" do
          before do
            allow(teacher).to receive(:sanctions).and_return(
              [
                instance_double(
                  Sanction, possible_match_on_childrens_barred_list?: false, guilty_but_not_prohibited?: true
                ),
                instance_double(
                  Sanction, possible_match_on_childrens_barred_list?: false, guilty_but_not_prohibited?: false
                )
              ]
            )
          end

          it "does not add the No restrictions tag" do
            render_inline described_class.new(teacher)

            expect(page).not_to have_text("No restrictions")
          end
        end
      end
    end
  end
end
