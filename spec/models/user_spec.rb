require "rails_helper"

RSpec.describe User, type: :model do
  describe ".from_identity" do
    let(:auth_data) do
      OpenStruct.new(
        info:
          OpenStruct.new(
            email: "test@example.com",
            name: "Test User",
            first_name: "Test",
            last_name: "User"
          ),
        extra: OpenStruct.new(raw_info: OpenStruct.new(birthdate: "1986-01-02", trn: "123456"))
      )
    end

    it "creates a new user with the auth data" do
      user = described_class.from_identity(auth_data)

      expect(user.email).to eq "test@example.com"
      expect(user.name).to eq "Test User"
      expect(user.given_name).to eq "Test"
      expect(user.family_name).to eq "User"
      expect(user.trn).to eq "123456"
      expect(user.date_of_birth.to_s).to eq "1986-01-02"
    end

    context "a user exists" do
      let!(:user) { create(:user, email: "test@example.com", given_name: "Ray") }

      it "updates the user's details" do
        described_class.from_identity(auth_data)
        expect(user.reload.given_name).to eq "Test"
        expect(User.count).to eq 1
      end
    end
  end
end
