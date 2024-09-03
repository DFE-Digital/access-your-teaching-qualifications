require 'rails_helper'

RSpec.describe BulkSearch, type: :model do
  it { is_expected.to validate_presence_of(:file) }

  context 'when the file is present' do
    subject { described_class.new(file:) }
    let(:file) { fixture_file_upload('spec/fixtures/valid_bulk_search.csv') }

    it { is_expected.to be_valid }
  end

  context 'when the header row is missing' do
    let(:bulk_search) { described_class.new(file:) }
    let(:file) { fixture_file_upload('spec/fixtures/invalid_bulk_search.csv') }

    it 'adds an error' do
      bulk_search.valid?

      expect(bulk_search.errors[:file]).to include('The selected file must use the template')
    end
  end

  context 'when the file is missing a TRN' do
    let(:bulk_search) { described_class.new(file:) }
    let(:file) { fixture_file_upload('spec/fixtures/invalid_bulk_search_missing_trn.csv') }

    it 'adds an error' do
      bulk_search.valid?

      expect(bulk_search.errors[:file]).to include('The selected file does not have a TRN in row 1')
    end
  end

  context 'when the file is missing a Date of birth' do
    let(:bulk_search) { described_class.new(file:) }
    let(:file) { fixture_file_upload('spec/fixtures/invalid_bulk_search_missing_date_of_birth.csv') }

    it 'adds an error' do
      bulk_search.valid?

      expect(bulk_search.errors[:file]).to include('The selected file does not have a date of birth in row 1')
    end
  end

  context 'when the file has an invalid date of birth' do
    let(:bulk_search) { described_class.new(file:) }
    let(:file) { fixture_file_upload('spec/fixtures/invalid_bulk_search_invalid_date_of_birth.csv') }

    it 'adds an error' do
      bulk_search.valid?

      expect(bulk_search.errors[:file]).to include('The date of birth in row 1 must be in DD/MM/YYYY format')
    end
  end

  describe '#call', test: :with_fake_quals_api do
    subject(:call) { described_class.new(file:).call }

    let(:file) { fixture_file_upload('spec/fixtures/valid_bulk_search.csv') }

    it { is_expected.to be_truthy }
    it { is_expected.to be_an_instance_of(Array) }

    it 'returns the total count of records found' do
      expect(call.first).to eq(1)
    end

    it 'returns the records found' do
      expect(call.second).to all(be_an_instance_of(QualificationsApi::Teacher))
    end

    it 'returns the records not found' do
      expect(call.third).to eq(["trn" => '3001403', "date_of_birth" => Date.parse('01/01/1990')])
    end

    context 'when the bulk search is not valid' do
      let(:file) { nil }

      it { is_expected.to be_falsey }
    end

    context 'when the search returns an error' do
      before do
        allow_any_instance_of(QualificationsApi::Client).to receive(:bulk_teachers).and_return(nil)
      end

      it "returns no results" do
        is_expected.to eq([0, [], 
          [
            { "trn" => "3001403", "date_of_birth" => Date.parse("01/01/1990") },
            { "date_of_birth" => Date.parse("1/1/2000"), "trn" => "9876543" }
          ]
        ])
      end
    end
  end
end