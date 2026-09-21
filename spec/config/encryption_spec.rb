require "rails_helper"

# Key derivation moved from SHA-1 to SHA-256, which no ciphertext records, so a
# silent revert of the configuration would not surface until rows stopped
# decrypting in production. These assert the intended state directly.
RSpec.describe "Active Record encryption configuration" do
  let(:config) { ActiveRecord::Encryption.config }

  it "derives keys with SHA-256" do
    expect(config.hash_digest_class).to eq OpenSSL::Digest::SHA256
  end

  # support_sha1_for_non_deterministic_encryption is a writer with no reader: it
  # appends a previous scheme. Assert what it buys instead of whether it was set.
  it "still reads non-deterministic columns written before the change" do
    user = create(:user, given_name: "Ada")
    write_under_sha1(user, :given_name, "Ada")

    expect(user.reload.given_name).to eq "Ada"
  end

  it "gives non-deterministic columns a SHA-1 fallback" do
    expect(User.type_for_attribute(:given_name).previous_types).not_to be_empty
  end

  it "gives the deterministic email columns no SHA-1 fallback of their own" do
    aggregate_failures do
      expect(User.type_for_attribute(:email).previous_types).to be_empty
      expect(DsiUser.type_for_attribute(:email).previous_types).to be_empty
    end
  end

  # These are named rather than derived, so the specs have to be what keeps them
  # honest. An attribute added to a model, or its determinism changed, would
  # otherwise be silently left on the old digest.
  describe "the named attribute lists" do
    let(:declared) do
      Pii::ENCRYPTED_ATTRIBUTES.keys.index_with { |name| name.constantize.encrypted_attributes.to_a }
    end

    it "covers every encrypted attribute the models declare" do
      expect(Pii::ENCRYPTED_ATTRIBUTES.transform_values(&:sort))
        .to eq declared.transform_values(&:sort)
    end

    it "marks exactly the attributes the models treat as deterministic" do
      deterministic = declared.to_h do |name, attributes|
        model = name.constantize
        [name, attributes.select { |a| model.type_for_attribute(a).deterministic? }]
      end

      expect(Pii::DETERMINISTIC_ATTRIBUTES)
        .to eq(deterministic.reject { |_, attributes| attributes.empty? })
    end
  end
end
