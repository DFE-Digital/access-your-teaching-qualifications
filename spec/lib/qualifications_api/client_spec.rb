require "rails_helper"

RSpec.describe QualificationsApi::Client do
  describe "#teacher" do
    it "returns details for the currently authenticated teacher" do
      client = described_class.new(token: "token")
      response = client.teacher

      expect(response).to be_a(QualificationsApi::Teacher)
      expect(response.first_name).to eq "Terry"
    end

    context "with an invalid token" do
      it "raises an error" do
        client = described_class.new(token: "invalid-token")

        expect { client.teacher }.to raise_error(QualificationsApi::InvalidTokenError)
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
