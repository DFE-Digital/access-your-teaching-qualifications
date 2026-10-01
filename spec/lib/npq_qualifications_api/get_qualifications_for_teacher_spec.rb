require "rails_helper"

RSpec.describe NpqQualificationsApi::GetQualificationsForTeacher do
  subject(:call) { described_class.new(trn: "1234567").call }

  let(:npq_url) { %r{/api/teacher-record-service/v1/qualifications/1234567} }
  let(:json_headers) { { "Content-Type" => "application/json" } }

  def body_with(qualifications)
    { data: { trn: "1234567", qualifications: } }.to_json
  end

  describe "#call" do
    context "when the response is well formed" do
      it "returns the response" do
        stub_request(:get, npq_url).to_return(status: 200, headers: json_headers,
                                              body: body_with([{ award_date: "2023-02-27", npq_type: "NPQH" }]))

        expect(call.body.dig("data", "qualifications")).to eq([{ "award_date" => "2023-02-27", "npq_type" => "NPQH" }])
      end
    end

    context "when the teacher has no NPQs" do
      it "returns the response" do
        stub_request(:get, npq_url).to_return(status: 200, headers: json_headers, body: body_with([]))

        expect(call.body.dig("data", "qualifications")).to eq([])
      end
    end

    [nil, "", "  "].each do |award_date|
      context "when a qualification's award_date is #{award_date.inspect}" do
        it "returns the response, since an undated NPQ still renders" do
          stub_request(:get, npq_url).to_return(status: 200, headers: json_headers,
                                                body: body_with([{ award_date:, npq_type: "NPQH" }]))

          expect(call).to be_success
        end
      end
    end

    {
      "an HTML page" => { headers: { "Content-Type" => "text/html" }, body: "<html>Maintenance</html>" },
      "a blank JSON body" => { headers: { "Content-Type" => "application/json" }, body: "" },
      "a JSON array" => { headers: { "Content-Type" => "application/json" }, body: "[]" },
      "no data" => { headers: { "Content-Type" => "application/json" }, body: { trn: "1234567" }.to_json },
      "no qualifications" => { headers: { "Content-Type" => "application/json" },
                               body: { data: { trn: "1234567" } }.to_json },
    }.each do |description, response|
      context "when the response body is #{description}" do
        before { stub_request(:get, npq_url).to_return(status: 200, **response) }

        it "raises an ApiError" do
          expect { call }.to raise_error(NpqQualificationsApi::ApiError)
        end
      end
    end

    {
      "has no npq_type" => { award_date: "2023-02-27" },
      "has an unparseable award_date" => { award_date: "garbage", npq_type: "NPQH" },
      "has a non-string award_date" => { award_date: 20_230_227, npq_type: "NPQH" },
      "has an over-long award_date" => { award_date: "2" * 200, npq_type: "NPQH" },
    }.each do |description, qualification|
      context "when a qualification #{description}" do
        before do
          stub_request(:get, npq_url).to_return(status: 200, headers: json_headers, body: body_with([qualification]))
        end

        it "raises an ApiError" do
          expect { call }.to raise_error(NpqQualificationsApi::ApiError)
        end
      end
    end

    context "when a qualification has an unrecognised npq_type" do
      before do
        allow(Sentry).to receive(:capture_message)
        stub_request(:get, npq_url).to_return(status: 200, headers: json_headers,
                                              body: body_with([{ award_date: "2023-02-27", npq_type: "NPQXYZ" }]))
      end

      it "returns the response and reports the type to Sentry" do
        aggregate_failures do
          expect(call).to be_success
          expect(Sentry).to have_received(:capture_message).with(/NPQXYZ/)
        end
      end

      context "with a warm cache" do
        # Rails.cache is a :null_store in the test environment
        before { allow(Rails).to receive(:cache).and_return(ActiveSupport::Cache.lookup_store(:memory_store)) }

        it "reports the type once per cache fill, not on every call" do
          2.times { described_class.new(trn: "1234567").call }

          expect(Sentry).to have_received(:capture_message).once
        end
      end
    end
  end
end
