require "rails_helper"

RSpec.describe User, type: :model do
  describe ".from_identity" do
    let(:auth_data) do
      OpenStruct.new(
        info:
          OpenStruct.new(
            email: "test@example.com",
            name: "Test User",
            given_name: "Test",
            family_name: "User",
            trn: "123456",
            date_of_birth: "1986-01-02"
          )
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
      let!(:user) do
        create(:user, email: "test@example.com", given_name: "Ray")
      end

      it "updates the user's details" do
        described_class.from_identity(auth_data)
        expect(user.reload.given_name).to eq "Test"
        expect(User.count).to eq 1
      end
    end
  end
end
