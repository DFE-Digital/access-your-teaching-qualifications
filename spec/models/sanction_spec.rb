require 'rails_helper'

RSpec.describe Sanction, type: :model do
  let(:api_data) do
    {
      code:,
      start_date:
    }
  end
  let(:code) { "A13" }
  let(:start_date) { "2020-10-25" }
  let(:sanction) { described_class.new(api_data) }

  describe '#title' do
    subject { sanction.title }

    context 'when type exists in SANCTIONS' do
      it { is_expected.to eq('Suspension order with conditions') }
    end

    context 'when type does not exist in SANCTIONS' do
      let(:code) { "Z99" }

      it { is_expected.to be_nil }
    end
  end

  describe '#description' do
    subject(:description) { sanction.description }

    context 'when type exists in SANCTIONS' do
      let(:code) { "G1" }
      
      it "returns the description as markdown" do
        expect(description)
          .to eq('Email the Disclosure and Barring Service (DBS) at [dbscost@dbs.gov.uk](mailto:dbscost@dbs.gov.uk) ' \
                 'to check if this person is allowed to work with children.')
      end
    end

    context 'when type does not exist in SANCTIONS' do
      let(:code) { "Z99" }

      it { is_expected.to be_nil }
    end
  end


  describe "start_date" do
    subject { sanction.start_date }

    it { is_expected.to eq(Date.parse(start_date)) }

    context "when startDate is not present" do
      let(:start_date) { nil }

      it { is_expected.to be nil }
    end
  end
end
