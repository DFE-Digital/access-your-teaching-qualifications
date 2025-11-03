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

    context "with caching enabled" do
      let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }
      let(:npq_request_domain) do
        "#{ENV.fetch("NPQ_QUALIFICATIONS_API_URL")}api/teacher-record-service/v1/qualifications/1234567"
      end

      # Turn on caching temporarily so we can test this properly since
      # Rails.cache is set to :null_store in the test environment
      before do
        allow(Rails).to receive(:cache).and_return(memory_store)
        Rails.cache.clear
      end

      it "makes a request to the correct NPQ endpoint when loading the teacher and caches the result" do
        # load the cache on first request
        client = described_class.new(token: "token")
        client.teacher(trn: "1234567")

        # second request should hit the cache
        client = described_class.new(token: "token")
        response = client.teacher(trn: "1234567")

        expect(WebMock).to have_requested(:get, npq_request_domain).once

        travel 16.minutes do
          # after 15 minutes we should make the request again and not hit the cache
          client = described_class.new(token: "token")
          response = client.teacher(trn: "1234567")

          expect(WebMock).to have_requested(:get, npq_request_domain).twice
        end
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

    context "when the API times out" do
      before do
        stub_request(:get, %r{.*}).to_timeout
      end

      it "raises an error" do
        client = described_class.new(token: "token")

        expect { client.teacher }.to raise_error(QualificationsApi::ApiError)
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

  describe "#bulk_teachers" do
    subject(:bulk_teachers) do
      described_class.new(token:).bulk_teachers(queries:)
    end

    let(:token) { "token" }
    let(:queries) { [] }
    
    it "returns the total count of records found" do
      expect(bulk_teachers["total"]).to eq(1)
    end

    it "returns the records found" do
      expect(bulk_teachers.dig("results", 0, "trn")).to eq("9876543")
    end

    context "when the API returns a 401" do
      let(:token) { "invalid-token" }

      it "raises an error" do
        expect { bulk_teachers }.to raise_error(
          QualificationsApi::InvalidTokenError
        )
      end
    end

    context "when the API returns a 403" do
      let(:token) { "forbidden" }

      it "raises an error" do
        expect { bulk_teachers }.to raise_error(
          QualificationsApi::ForbiddenError
        )
      end
    end

    context "when the API returns a 500" do
      let(:token) { "api-error" }

      it "captures the error in Sentry" do
        expect(Sentry).to receive(:capture_exception)
        bulk_teachers
      end
    end
  end
end
