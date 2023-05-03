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

        expect { client.teacher }.to raise_error(QualificationsApi::InvalidTokenError)
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
  end

  describe "#certificate" do
    it "returns a PDF certificate" do
      client = described_class.new(token: "token")
      response = client.certificate(type: :qts)

      expect(response).to eq "pdf data"
    end

    context "with an invalid token" do
      it "raises an error" do
        client = described_class.new(token: "invalid-token")

        expect { client.certificate(type: :qts) }.to raise_error(
          QualificationsApi::InvalidTokenError
        )
      end
    end
  end
end
