require "rails_helper"

RSpec.describe User, type: :model do
  describe ".from_auth" do
    let(:uid) { "123-abc" }
    let(:provider) { "an-oauth2-provider" }
    let(:email) { "test@example.com" }
    let(:auth_data) do
      OpenStruct.new(
        uid:,
        provider:,
        info:
          OpenStruct.new(
            email:,
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

    context "when no user matches the uid or email" do
      it "creates a new user with the auth data" do
        expect { described_class.from_auth(auth_data) }.to change(User, :count).by(1)

        user = User.last
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
    end

    context "when a user already has the uid and provider" do
      let!(:existing) do
        create(:user, auth_uuid: uid, auth_provider: provider, email: "old@example.com", given_name: "Ray")
      end

      it "returns the existing user without creating a new one" do
        expect { expect(described_class.from_auth(auth_data)).to eq(existing) }
          .not_to change(User, :count)
      end

      it "refreshes the mutable details from the auth payload" do
        described_class.from_auth(auth_data)

        expect(existing.reload.given_name).to eq "Test"
        expect(existing.email).to eq email
      end
    end

    context "when a user exists by email but has no uid yet (pre-cutover)" do
      let!(:existing) do
        create(:user, email:, auth_uuid: nil, auth_provider: nil, given_name: "Ray")
      end

      it "backfills the uid and provider onto that record" do
        expect { described_class.from_auth(auth_data) }.not_to change(User, :count)
        expect(existing.reload).to have_attributes(auth_uuid: uid, auth_provider: provider)
      end
    end

    context "when the email already belongs to a user with a different uid" do
      let!(:existing) do
        create(:user, email:, auth_uuid: "other-uid", auth_provider: provider)
      end

      it "creates a separate user for the new subject, sharing the email" do
        expect { described_class.from_auth(auth_data) }.to change(User, :count).by(1)

        new_user = User.find_by(auth_uuid: uid)
        expect(new_user).not_to eq(existing)
        expect(new_user.email).to eq(email)
        expect(new_user.auth_provider).to eq(provider)
      end

      it "leaves the existing user untouched" do
        described_class.from_auth(auth_data)

        expect(existing.reload).to have_attributes(auth_uuid: "other-uid", email:)
      end
    end

    context "when the auth payload has no uid" do
      let(:uid) { nil }

      it "raises AuthMissingUidError" do
        expect { described_class.from_auth(auth_data) }.to raise_error(
          User::AuthMissingUidError
        )
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
