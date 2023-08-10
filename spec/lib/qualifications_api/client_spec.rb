require "rails_helper"

RSpec.describe QualificationsApi::Client, test: :with_fake_quals_api do
  describe "#teacher" do
    it "returns details for the currently authenticated teacher" do
      client = described_class.new(token: "token")
      response = client.teacher

      expect(response).to be_a(QualificationsApi::Teacher)
      expect(response.trn).to eq "3000299"
    end

    context "with an invalid token" do
      it "raises an error" do
        client = described_class.new(token: "invalid-token")

        expect { client.teacher }.to raise_error(
          QualificationsApi::InvalidTokenError
        )
      end
    end

    context "when a trn is provided" do
      it "returns details for that trn" do
        client = described_class.new(token: "token")
        response = client.teacher(trn: "1234567")

        expect(response).to be_a(QualificationsApi::Teacher)
        expect(response.trn).to eq "1234567"
      end
    end

    context "when an invalid trn is provided" do
      it "raises an error" do
        client = described_class.new(token: "token")
        expect { client.teacher(trn: "bad-trn") }.to raise_error(
          QualificationsApi::TeacherNotFoundError
        )
      end
    end
  end

  describe "#certificate" do
    subject(:certificate) do
      described_class.new(token:).certificate(name:, type:, url:)
    end

    let(:name) { "Steven Toast" }
    let(:token) { "token" }
    let(:type) { :qts }
    let(:url) { "/v3/certificates/qts" }

    it { is_expected.to be_a(QualificationsApi::Certificate) }

    it "returns a PDF certificate" do
      expect(certificate.file_data).to eq "pdf data"
      expect(certificate.file_name).to eq "Steven Toast_qts_certificate.pdf"
    end

    context "with an invalid token" do
      let(:token) { "invalid-token" }

      it "raises an error" do
        expect { certificate }.to raise_error(
          QualificationsApi::InvalidTokenError
        )
      end
    end

    context "with an invalid certificate url" do
      let(:url) { "/some/invalid/url" }

      it "raises an error" do
        expect { certificate }.to raise_error(
          QualificationsApi::InvalidCertificateUrlError
        )
      end
    end
  end

  describe "#teachers" do
    subject do
      described_class.new(token: "token").teachers(date_of_birth:, last_name:)
    end

    let(:date_of_birth) { "1990-01-01" }
    let(:last_name) { "Walsh" }

    it "returns a list of teachers" do
      expect(subject.first).to eq 1
      expect(subject.last).to all(be_a(QualificationsApi::Teacher))
    end

    context "when there are no matches" do
      let(:last_name) { "NotAMatch" }

      it "returns an empty list" do
        expect(subject.first).to eq 0
        expect(subject.last).to eq []
      end
    end

    context "when the API returns a 500 error" do
      before { stub_request(:get, /teachers/).to_return(status: 500) }

      it "returns an empty list" do
        expect(subject.first).to eq 0
        expect(subject.last).to eq []
      end
    end
  end
end
