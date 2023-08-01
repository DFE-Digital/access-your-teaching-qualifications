require "rails_helper"

RSpec.describe QualificationsApi::Certificate, type: :model do
  describe "#file_name" do
    subject { described_class.new(name:, type:, file_data:).file_name }

    let(:file_data) { "pdf data" }
    let(:name) { "Steven Toast" }
    let(:type) { "qts" }

    it { is_expected.to eq("Steven Toast_qts_certificate.pdf") }
  end
end
