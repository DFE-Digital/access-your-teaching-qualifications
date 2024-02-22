require "rails_helper"

RSpec.describe DfESignInApi::GetUserAccessToService do
  describe "#call" do
    let(:org_id) { "123" }
    let(:user_id) { "456" }
    let(:role_id) { "789" }
    let(:role_code) { create(:role, :enabled).code }
    let(:internal_role_code) { create(:role, :enabled, :internal).code }
    let(:endpoint) do
      "#{ENV.fetch("DFE_SIGN_IN_API_BASE_URL")}/services/checkrecordteacher/organisations/#{org_id}/users/#{user_id}"
    end

    subject { described_class.new(org_id:, user_id:).call }

    context "when the user is authorised" do
      before do
        stub_request(:get, endpoint)
        .to_return_json(
          status: 200,
          body: { "roles" => [{ "id" => role_id, "code" => role_code }] },
        )
      end

      it { is_expected.to eq({ "id" => role_id, "code" => role_code }) }
    end

    context "when the user is not authorised" do
      before do
        stub_request(:get, endpoint)
        .to_return_json(
          status: 200,
          body: { "roles" => [{ "id" => role_id, "code" => "Unauthorised_Role" }] },
        )
      end

      it { is_expected.to be_nil }
    end

    context "when the user has an internal and external role" do
      before do
        stub_request(:get, endpoint)
        .to_return_json(
          status: 200,
          body: {
            "roles" => [
              { "id" => role_id, "code" => role_code },
              { "id" => role_id, "code" => internal_role_code }
            ]
          },
        )
      end

      it { is_expected.to eq({ "id" => role_id, "code" => internal_role_code }) }
    end
  end
end
