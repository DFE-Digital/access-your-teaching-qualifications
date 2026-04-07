require 'rails_helper'

RSpec.describe Sanction, type: :model do
  let(:api_data) do
    {
      alert_type: {
        alert_type_id:,
      },
      start_date:
    }
  end
  let(:alert_type_id) { "1a2b06ae-7e9f-4761-b95d-397ca5da4b13" }
  let(:start_date) { "2020-10-25" }
  let(:alert) { described_class.new(api_data) }

  describe '#title' do
    subject { alert.title }

    context 'when type exists in SANCTIONS' do
      it { is_expected.to eq('Suspension order with conditions') }
    end

    context 'when type does not exist in SANCTIONS' do
      let(:alert_type_id) { "Z99" }

      it { is_expected.to be_nil }
    end
  end

  describe '#description' do
    subject(:description) { alert.description }

    context 'when type exists in SANCTIONS' do
      let(:alert_type_id) { "1a2b06ae-7e9f-4761-b95d-397ca5da4b13" }
      
      it "returns the description as markdown" do
        expect(description)
          .to include('Suspended by the General Teaching Council for England.')
      end
    end

    context 'when type does not exist in SANCTIONS' do
      let(:alert_type_id) { "0000000-7e9f-4761-b95d-0000000000" }

      it { is_expected.to be_nil }
    end
  end


  describe "start_date" do
    subject { alert.start_date }

    it { is_expected.to eq(Date.parse(start_date)) }

    context "when startDate is not present" do
      let(:start_date) { nil }

      it { is_expected.to be nil }
    end
  end
end
