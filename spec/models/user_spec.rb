require "rails_helper"

RSpec.describe User, type: :model do
  describe ".from_auth" do
    let(:auth_data) do
      OpenStruct.new(
        uid: "123-abc",
        provider: "an-oauth2-provider",
        info:
          OpenStruct.new(
            email: "test@example.com",
            name: "Test User",
            first_name: "Test",
            last_name: "User"
          ),
        extra: OpenStruct.new(
          raw_info: OpenStruct.new(
            birthdate: "1986-01-02",
            trn: "123456",
            onelogin_verified_names: [["Test User"]],
            onelogin_verified_birthdates: ["1992-02-03"]
          )
        )
      )
    end

    it "creates a new user with the auth data" do
      user = described_class.from_auth(auth_data)

      expect(user.email).to eq "test@example.com"
      expect(user.name).to eq "Test User"
      expect(user.given_name).to eq "Test"
      expect(user.family_name).to eq "User"
      expect(user.trn).to eq "123456"
      expect(user.date_of_birth.to_s).to eq "1986-01-02"
      expect(user.auth_uuid).to eq "123-abc"
      expect(user.auth_provider).to eq "an-oauth2-provider"
      expect(user.one_login_verified_name).to eq "Test User"
      expect(user.one_login_verified_birth_date.to_s).to eq "1992-02-03"
    end

    context "a user exists" do
      let!(:user) { create(:user, email: "test@example.com", given_name: "Ray") }

      it "updates the user's details" do
        described_class.from_auth(auth_data)
        expect(user.reload.given_name).to eq "Test"
        expect(User.count).to eq 1
      end
    end
  end

  describe "#verified_by_one_login?" do
    let(:user) { build(:user) }
    before do
      user.one_login_verified_name = "Test User"
      user.one_login_verified_birth_date = "1992-02-03".to_date
    end

    it "is true is both one login verified fields present" do
      expect(user.verified_by_one_login?).to eq true
    end

    it "is false if one_login_verified_name is missing" do
      user.one_login_verified_name = nil

      expect(user.verified_by_one_login?).to eq false
    end

    it "is false if one_login_verified_birth_date is missing" do
      user.one_login_verified_birth_date = nil

      expect(user.verified_by_one_login?).to eq false
    end
  end
end
