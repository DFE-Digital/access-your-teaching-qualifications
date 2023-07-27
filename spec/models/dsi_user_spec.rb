require "rails_helper"

RSpec.describe DsiUser, type: :model do
  describe ".create_or_update_from_dsi" do
    subject(:create_or_update_from_dsi) do
      described_class.create_or_update_from_dsi(dsi_payload)
    end

    let(:company_registration_number) { nil }
    let(:dsi_payload) do
      OmniAuth::AuthHash.new(
        uid: "123456",
        info: {
          email:,
          first_name: "John",
          last_name: "Doe"
        },
        extra: {
          raw_info: {
            organisation: {
              companyRegistrationNumber: company_registration_number
            }
          }
        }
      )
    end
    let(:email) { "test@example.com" }

    context "when the user with the email exists" do
      let!(:existing_user) { create(:dsi_user, email:) }

      it { is_expected.to eq(existing_user) }

      it "updates the attributes" do
        expect(create_or_update_from_dsi).to have_attributes(
          first_name: dsi_payload.info.first_name,
          last_name: dsi_payload.info.last_name,
          uid: dsi_payload.uid
        )
      end
    end

    context "when the user with the email does not exist" do
      it "creates a new user" do
        expect { create_or_update_from_dsi }.to change { DsiUser.count }.from(
          0
        ).to(1)
      end

      it "sets the attributes" do
        create_or_update_from_dsi
        expect(DsiUser.first).to have_attributes(
          first_name: dsi_payload.info.first_name,
          last_name: dsi_payload.info.last_name,
          uid: dsi_payload.uid
        )
      end
    end

    context "when the user has a valid organisation" do
      let(:company_registration_number) { "1234" }

      before do
        create(:organisation, company_registration_number:)
      end

      it { is_expected.to be_valid_organisation }
    end

    context "when the user has an invalid organisation" do
      let(:company_registration_number) { "not_found" }

      it { is_expected.not_to be_valid_organisation }
    end
  end
end
