require "rails_helper"

# Key derivation moved from SHA-1 to SHA-256, which no ciphertext records, so a
# silent revert of the configuration would not surface until rows stopped
# decrypting in production. These assert the intended end state directly.
RSpec.describe "Active Record encryption configuration" do
  let(:config) { ActiveRecord::Encryption.config }

  it "derives keys with SHA-256" do
    expect(config.hash_digest_class).to eq OpenSSL::Digest::SHA256
  end

  it "keeps no previous schemes, so SHA-256 is the only digest that can read" do
    expect(config.previous_schemes).to be_empty
  end

  it "gives no encrypted attribute a fallback to an older digest" do
    types = %i[email given_name].map { |attribute| User.type_for_attribute(attribute) }

    expect(types.map(&:previous_types)).to all(be_empty)
  end

  # The counterpart of this ran green before support_sha1_for_non_deterministic_encryption
  # was removed. Anything still holding SHA-1 ciphertext is now unreadable for good,
  # which is why pii:verify had to report nothing before this change shipped.
  context "with a row still written under SHA-1" do
    it "cannot read a non-deterministic column" do
      user = create(:user, given_name: "Ada")
      write_under_sha1(user, :given_name, "Ada")

      expect { user.reload.given_name }.to raise_error(ActiveRecord::Encryption::Errors::Decryption)
    end

    it "cannot find a deterministic column by lookup" do
      user = create(:user, email: "legacy@example.com")
      write_under_sha1(user, :email, "legacy@example.com")

      expect(User.find_by(email: "legacy@example.com")).to be_nil
    end
  end
end
