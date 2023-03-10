require "rails_helper"

RSpec.describe QualificationsApi::Teacher, type: :model do
  describe "#qts_date" do
    subject(:qts_date) { teacher.qts_date }

    let(:api_data) { { "qtsDate" => "2015-11-01" } }
    let(:teacher) { described_class.new(api_data) }

    it { is_expected.to eq(Date.new(2015, 11, 1)) }

    context "when the qtsDate is nil" do
      let(:api_data) { { "qtsDate" => nil } }

      it { is_expected.to be_nil }
    end
  end
end
