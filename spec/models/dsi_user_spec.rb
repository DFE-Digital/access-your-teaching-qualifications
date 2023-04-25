require "rails_helper"

RSpec.describe DsiUser, type: :model do
  describe ".create_or_update_from_dsi" do
    let(:dsi_payload) do
      OmniAuth::AuthHash.new(info: { email:, first_name: "John", last_name: "Doe", uid: "123456" })
    end
    let(:email) { "test@example.com" }

    context "when the user with the email exists" do
      let!(:existing_user) { create(:dsi_user, email:) }

      it "finds the existing user and updates the attributes" do
        result = described_class.create_or_update_from_dsi(dsi_payload)
        expect(result).to eq(existing_user)
        updated_fields = %w[first_name last_name uid]
        expect(result.attributes.slice(*updated_fields)).to eq(
          dsi_payload.info.slice(*updated_fields)
        )
      end
    end

    context "when the user with the email does not exist" do
      it "creates a new user" do
        expect { described_class.create_or_update_from_dsi(dsi_payload) }.to change {
          DsiUser.count
        }.from(0).to(1)
        updated_fields = %w[first_name last_name uid]
        expect(DsiUser.first.attributes.slice(*updated_fields)).to eq(
          dsi_payload.info.slice(*updated_fields)
        )
      end
    end
  end
end
