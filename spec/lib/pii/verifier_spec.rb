require "rails_helper"

RSpec.describe Pii::Verifier do
  subject(:verifier) { described_class.new(logger: Logger.new(log)) }

  let(:log) { StringIO.new }

  describe "#call" do
    context "when every row was written under the current digest" do
      it "counts nothing" do
        create(:user)
        create(:dsi_user)

        expect(verifier.call).to be_zero
      end
    end

    context "when a deterministic column still holds SHA-1 ciphertext" do
      it "counts it and names it in the log" do
        user = create(:user)
        write_under_sha1(user, :email, "legacy@example.com")

        aggregate_failures do
          expect(verifier.call).to eq 1
          expect(log.string).to include "User##{user.id}.email"
        end
      end
    end

    # The model's own type has a SHA-1 fallback while
    # support_sha1_for_non_deterministic_encryption is set, so it reads these rows
    # happily. Verification has to see them anyway, because they become unreadable
    # the moment that setting is removed.
    context "when a non-deterministic column still holds SHA-1 ciphertext" do
      it "counts it even though the application can still read it" do
        user = create(:user, given_name: "Ada")
        write_under_sha1(user, :given_name, "Ada")

        aggregate_failures do
          expect(user.reload.given_name).to eq "Ada"
          expect(verifier.call).to eq 1
        end
      end
    end

    context "after the re-encryptor has run" do
      it "counts nothing" do
        user = create(:user)
        dsi_user = create(:dsi_user)
        write_under_sha1(user, :email, user.email)
        write_under_sha1(dsi_user, :first_name, "Steven")

        Pii::ReEncryptor.new(logger: Logger.new(File::NULL)).call

        expect(verifier.call).to be_zero
      end
    end

    # The two console tables are last in the model order. A sample shared across
    # models would report their counts and never any of their ids.
    context "when an earlier model has more failures than the sample holds" do
      it "still names the later models in the log" do
        stub_const("#{described_class}::SAMPLE_LIMIT", 2)
        3.times { write_under_sha1(create(:user), :email, "legacy@example.com") }
        command = create_console_command(statements: "User.count")
        write_under_sha1(command, :statements, "User.count")

        aggregate_failures do
          expect(verifier.call).to eq 4
          expect(log.string).to include "Console1984::Command##{command.id}.statements"
        end
      end
    end

    context "with unreadable rows in more than one model" do
      it "sums the counts across all of them" do
        write_under_sha1(create(:user), :email, "legacy@example.com")
        write_under_sha1(create(:dsi_user), :first_name, "Steven")
        write_under_sha1(create_console_command(statements: "User.count"), :statements, "User.count")

        expect(verifier.call).to eq 3
      end
    end

    # handle_deserialize_error returns the raw ciphertext instead of raising when
    # support_unencrypted_data is true, and Scheme inherits that from the global
    # unless the scheme pins it. Inheriting a true would report every row readable
    # and take the gate in front of the irreversible cleanup silently green.
    context "when support_unencrypted_data is enabled globally" do
      it "still counts a SHA-1 row" do
        user = create(:user)
        write_under_sha1(user, :email, "legacy@example.com")
        allow(ActiveRecord::Encryption.config).to receive(:support_unencrypted_data).and_return(true)

        expect(verifier.call).to be_positive
      end
    end

    # A missing key is not a property of any row. Reported as unreadable rows it
    # would look like mass corruption and point at a restore.
    context "when the encryption configuration is broken" do
      it "raises rather than reporting every row unreadable" do
        create(:user)
        allow(ActiveRecord::Encryption.config).to receive(:deterministic_key).and_raise(
          ActiveRecord::Encryption::Errors::Configuration, "Missing Active Record encryption credential"
        )

        expect { verifier.call }.to raise_error(
          ActiveRecord::Encryption::Errors::Configuration, /Missing Active Record encryption credential/
        )
      end
    end

    context "when an encrypted column is NULL" do
      it "does not count it" do
        create(:user, one_login_verified_name: nil)

        expect(verifier.call).to be_zero
      end
    end
  end

  def create_console_command(statements:)
    user = Console1984::User.create!(username: "auditor")
    session = Console1984::Session.create!(user:)
    Console1984::Command.create!(session:, statements:)
  end
end
