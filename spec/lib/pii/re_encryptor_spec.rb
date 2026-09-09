require "rails_helper"

RSpec.describe Pii::ReEncryptor do
  subject(:re_encryptor) { described_class.new(logger: Logger.new(File::NULL)) }

  describe "#call" do
    context "when rows were written under SHA-1" do
      it "makes every encrypted attribute readable under SHA-256 alone" do
        user = create(:user, email: "sha1@example.com", given_name: "Ada", name: "Ada Lovelace")
        write_under_sha1(user, :email, "sha1@example.com")
        write_under_sha1(user, :given_name, "Ada")

        re_encryptor.call

        aggregate_failures do
          expect(readable_under_sha256?(user, :email)).to be true
          expect(readable_under_sha256?(user, :given_name)).to be true
          expect(user.reload.email).to eq "sha1@example.com"
          expect(user.given_name).to eq "Ada"
        end
      end

      it "converts DsiUser as well as User" do
        dsi_user = create(:dsi_user, email: "dsi@example.com", first_name: "Steven")
        write_under_sha1(dsi_user, :email, "dsi@example.com")
        write_under_sha1(dsi_user, :first_name, "Steven")

        re_encryptor.call

        aggregate_failures do
          expect(readable_under_sha256?(dsi_user, :email)).to be true
          expect(readable_under_sha256?(dsi_user, :first_name)).to be true
          expect(dsi_user.reload.email).to eq "dsi@example.com"
        end
      end

      it "converts the console1984 and audits1984 columns, which no other sweep would reach" do
        command = create_console_command(statements: "User.count")
        audit = create_audit(notes: "looked fine")
        write_under_sha1(command, :statements, "User.count")
        write_under_sha1(audit, :notes, "looked fine")

        re_encryptor.call

        aggregate_failures do
          expect(readable_under_sha256?(command, :statements)).to be true
          expect(readable_under_sha256?(audit, :notes)).to be true
          expect(command.reload.statements).to eq "User.count"
          expect(audit.reload.notes).to eq "looked fine"
        end
      end

      it "spans more than one batch" do
        stub_const("#{described_class}::BATCH_SIZE", 2)
        users = create_list(:user, 5)
        users.each { |user| write_under_sha1(user, :email, user.email) }

        re_encryptor.call

        expect(users).to all(satisfy { |user| readable_under_sha256?(user, :email) })
      end
    end

    context "when a row was already converted" do
      it "leaves the value unchanged" do
        user = create(:user, email: "converted@example.com")

        expect { re_encryptor.call }.not_to(change { user.reload.email })
      end

      it "does not touch updated_at" do
        user = create(:user)
        user.update_column(:updated_at, 3.days.ago)

        expect { re_encryptor.call }.not_to(change { user.reload.updated_at })
      end
    end

    context "when an encrypted column is NULL" do
      it "leaves it NULL rather than encrypting a nil" do
        user = create(:user, one_login_verified_name: nil)

        re_encryptor.call

        expect(user.reload.read_attribute_before_type_cast(:one_login_verified_name)).to be_nil
      end
    end

    context "with a resume cursor" do
      it "skips rows before the cursor and converts the rest" do
        first, second = create_list(:user, 2)
        [first, second].each { |user| write_under_sha1(user, :email, user.email) }

        described_class.new(resume_model: "User", resume_id: second.id, logger: Logger.new(File::NULL)).call

        aggregate_failures do
          expect(readable_under_sha256?(first, :email)).to be false
          expect(readable_under_sha256?(second, :email)).to be true
        end
      end

      it "raises naming the models when given an unknown one" do
        expect { described_class.new(resume_model: "Widget", resume_id: 1) }
          .to raise_error(ArgumentError, /Widget is not one of/)
      end

      it "accepts a namespaced model name" do
        expect { described_class.new(resume_model: "Console1984::Command", resume_id: 88) }
          .not_to raise_error
      end

      it "skips models before the one the cursor names" do
        user = create(:user)
        dsi_user = create(:dsi_user)
        write_under_sha1(user, :email, user.email)
        write_under_sha1(dsi_user, :email, dsi_user.email)

        described_class.new(resume_model: "DsiUser", resume_id: dsi_user.id, logger: Logger.new(File::NULL)).call

        aggregate_failures do
          expect(readable_under_sha256?(user, :email)).to be false
          expect(readable_under_sha256?(dsi_user, :email)).to be true
        end
      end
    end

    # The verifier pins this too. If the writer inherits a global true,
    # handle_deserialize_error returns the raw ciphertext instead of raising, the
    # SHA-1 fallback never runs, and that ciphertext gets encrypted again as
    # though it were plaintext.
    context "when support_unencrypted_data is enabled globally" do
      it "still reads a SHA-1 row through the SHA-1 type" do
        user = create(:user)
        write_under_sha1(user, :email, "legacy@example.com")
        allow(ActiveRecord::Encryption.config).to receive(:support_unencrypted_data).and_return(true)

        re_encryptor.call

        expect(user.reload.email).to eq "legacy@example.com"
      end
    end

    context "when a value is readable under neither digest" do
      it "raises naming the row, because the bare error names only deserialize" do
        user = create(:user)
        write_raw(user, :email, "not ciphertext under any key")

        expect { re_encryptor.call }
          .to raise_error(ActiveRecord::Encryption::Errors::Base, /User##{user.id}/)
      end
    end
  end

  def create_console_command(statements:)
    user = Console1984::User.create!(username: "auditor")
    session = Console1984::Session.create!(user:)
    Console1984::Command.create!(session:, statements:)
  end

  # config.audits1984 sets auditor_class to Staff, which 20231030125347_drop_staff
  # removed, so an audit cannot be built through its association. The row still has
  # to be re-encryptable if that configuration is ever repaired.
  def create_audit(notes:)
    user = Console1984::User.create!(username: "reviewer")
    session = Console1984::Session.create!(user:)
    audit = Audits1984::Audit.new(session:, notes:)
    audit.auditor_id = user.id
    audit.save!(validate: false)
    audit
  end
end
