require 'rails_helper'

RSpec.describe Sanction, type: :model do
  describe '#title' do
    subject { sanction.title }

    context 'when type exists in SANCTIONS' do
      let(:sanction) { described_class.new(type: 'A13') }

      it { is_expected.to eq('Suspension order - with conditions') }
    end

    context 'when type does not exist in SANCTIONS' do
      let(:sanction) { described_class.new(type: 'Z99') }

      it { is_expected.to be_nil }
    end
  end
end
