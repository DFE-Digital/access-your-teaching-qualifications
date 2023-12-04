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

    context "when an unknown error occurs" do
      it "raises an error" do
        client = described_class.new(token: "api-error")

        expect { client.teacher }.to raise_error do |error|
          expect(error).to be_a(QualificationsApi::UnknownError)
          expect(error.message).to eq("API returned unhandled status 500")
        end
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
end
