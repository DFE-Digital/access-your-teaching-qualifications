require 'rails_helper'

RSpec.describe BulkSearch, type: :model do
  it { is_expected.to validate_presence_of(:file) }

  context 'when the file is present' do
    let(:bulk_search) { described_class.new(file:) }
    let(:file) { fixture_file_upload('spec/fixtures/valid_bulk_search.csv') }

    it 'validates the header row' do
      bulk_search.valid?

      expect(bulk_search.errors[:file]).to be_empty
    end

    context 'when the header row is missing' do
      let(:file) { fixture_file_upload('spec/fixtures/invalid_bulk_search.csv') }

      it 'adds an error' do
        bulk_search.valid?

        expect(bulk_search.errors[:file]).to include('The header row is missing or incorrect')
      end
    end
  end

  describe '#call', test: :with_fake_quals_api do
    subject(:call) { described_class.new(file:).call }

    let(:file) { fixture_file_upload('spec/fixtures/valid_bulk_search.csv') }

    it { is_expected.to be_truthy }
    it { is_expected.to be_an_instance_of(Array) }

    context 'when the bulk search is not valid' do
      let(:file) { nil }

      it { is_expected.to be_falsey }
    end
  end
end