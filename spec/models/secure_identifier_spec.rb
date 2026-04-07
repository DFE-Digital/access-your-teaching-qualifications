require 'rails_helper'

RSpec.describe SecureIdentifier do
  let(:plain_text) { 'Hello, World!' }

  describe '.encode' do
    subject { described_class.encode(plain_text) }

    it { is_expected.not_to eq(plain_text) }

    it 'returns a Base64 encoded string' do
      is_expected.to eq(
        Base64.strict_encode64(Base64.strict_decode64(SecureIdentifier.encode(plain_text)))
      )
    end

    context 'when given an empty string' do
      let(:plain_text) { '' }

      it { is_expected.to eq(plain_text) }
    end

    context 'when given nil' do
      let(:plain_text) { nil }

      it 'raises an ArgumentError' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end
  end

  describe '.decode' do
    subject { described_class.decode(encoded_text) }

    let(:encoded_text) { described_class.encode(plain_text) }

    it { is_expected.to eq(plain_text) }

    context 'when given an invalid Base64 string' do
      let(:encoded_text) { 'invalid' }

      it 'returns the passed value' do
        is_expected.to eq(encoded_text)
      end
    end

    context 'when given an empty string' do
      let(:encoded_text) { '' }

      it { is_expected.to eq(encoded_text) }
    end

    context 'when given nil' do
      let(:encoded_text) { nil }

      it 'raises an ArgumentError' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end
  end
end