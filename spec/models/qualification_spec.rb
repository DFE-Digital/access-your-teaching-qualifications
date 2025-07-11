require "rails_helper"

RSpec.describe Qualification, type: :model do
  describe "#certificate_type" do
    subject { qualification.certificate_type }

    let(:qualification) { described_class.new(type:) }
    let(:type) { :qts }

    it { is_expected.to eq(:qts) }

    context "when the qualification type is npq" do
      let(:type) { "npq-leading-teaching" }

      it { is_expected.to eq(:npq) }
    end
  end

  describe "#induction?" do
    subject { qualification.induction? }

    let(:qualification) { described_class.new(type:) }
    let(:type) { :qts }

    it { is_expected.to be_falsey }

    context "when the qualification type is induction" do
      let(:type) { :induction }

      it { is_expected.to be_truthy }
    end
  end

  describe "#rtps?" do
    subject { qualification.rtps? }

    let(:qualification) { described_class.new(type:) }
    let(:type) { :qts }

    it { is_expected.to be_falsey }

    context "when the qualification type is rtps" do
      let(:type) { :rtps }

      it { is_expected.to be_truthy }
    end

    context "when the qualification type is qts_rtps" do
      let(:type) { :qts_rtps }

      it { is_expected.to be_truthy }
    end

    context "when the qualification type is eyts_rtps" do
      let(:type) { :eyts_rtps }

      it { is_expected.to be_truthy }
    end
  end
end
