require "rails_helper"

RSpec.describe NpqQualificationsApi::Client do
  let(:client) { described_class.new(token: "token") }
  let(:endpoint) { "/api/teacher-record-service/v1/qualifications/1234567" }
  let(:npq_url) { %r{/api/teacher-record-service/v1/qualifications/1234567} }

  describe "#get" do
    context "when the API returns a successful response" do
      it "returns the response" do
        expect(client.get(endpoint)).to be_success
      end
    end

    context "when the API returns an error status" do
      before { stub_request(:get, npq_url).to_return(status: 500) }

      it "raises an ApiError naming the status" do
        expect { client.get(endpoint) }.to raise_error(NpqQualificationsApi::ApiError,
                                                       "API returned status 500")
      end
    end

    context "when the API times out" do
      before { stub_request(:get, npq_url).to_timeout }

      it "raises an ApiError" do
        expect { client.get(endpoint) }.to raise_error(NpqQualificationsApi::ApiError)
      end
    end

    context "when the TLS handshake fails" do
      before { stub_request(:get, npq_url).to_raise(Faraday::SSLError) }

      it "raises an ApiError" do
        expect { client.get(endpoint) }.to raise_error(NpqQualificationsApi::ApiError)
      end
    end
  end

  describe "#get_with_cache" do
    let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }

    # Rails.cache is a :null_store in the test environment
    before do
      allow(Rails).to receive(:cache).and_return(memory_store)
      stub_request(:get, npq_url).to_return(status: 500).then.to_rack(FakeNpqQualificationsApi)
    end

    context "when the API returns an error status" do
      it "does not cache the failed response" do
        aggregate_failures do
          expect { client.get_with_cache(endpoint, cache_key: "npq") }.to raise_error(NpqQualificationsApi::ApiError)
          expect(client.get_with_cache(endpoint, cache_key: "npq")).to be_success
          expect(WebMock).to have_requested(:get, npq_url).twice
        end
      end
    end

    context "when the app is redeployed" do
      before { stub_request(:get, npq_url).to_rack(FakeNpqQualificationsApi) }

      it "does not reuse responses cached by the previous release" do
        stub_const("ENV", ENV.to_h.merge("GIT_SHA" => "aaa"))
        client.get_with_cache(endpoint, cache_key: "npq")

        stub_const("ENV", ENV.to_h.merge("GIT_SHA" => "bbb"))
        client.get_with_cache(endpoint, cache_key: "npq")

        expect(WebMock).to have_requested(:get, npq_url).twice
      end
    end

    context "when the given block raises" do
      before { stub_request(:get, npq_url).to_rack(FakeNpqQualificationsApi) }

      it "does not cache the response" do
        reject_response = ->(_response) { raise NpqQualificationsApi::ApiError, "malformed" }

        aggregate_failures do
          expect { client.get_with_cache(endpoint, cache_key: "npq", &reject_response) }
            .to raise_error(NpqQualificationsApi::ApiError)
          expect(client.get_with_cache(endpoint, cache_key: "npq")).to be_success
          expect(WebMock).to have_requested(:get, npq_url).twice
        end
      end
    end
  end
end
