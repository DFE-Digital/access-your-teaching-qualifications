class DropStaff < ActiveRecord::Migration[7.0]
  def change
    reversible do |dir|
      dir.up do
        drop_table :staff
      end

      dir.down do
        create_table "staff" do |t|
          t.string :email, default: "", null: false
          t.string :encrypted_password, default: "", null: false
          t.string :reset_password_token
          t.datetime :reset_password_sent_at
          t.datetime :remember_created_at
          t.integer :sign_in_count, default: 0, null: false
          t.datetime :current_sign_in_at
          t.datetime :last_sign_in_at
          t.string :current_sign_in_ip
          t.string :last_sign_in_ip
          t.string :confirmation_token
          t.datetime :confirmed_at
          t.datetime :confirmation_sent_at
          t.string :unconfirmed_email
          t.integer :failed_attempts, default: 0, null: false
          t.string :unlock_token
          t.datetime :locked_at
          t.datetime :created_at, null: false
          t.datetime :updated_at, null: false
          t.datetime :invitation_accepted_at, precision: nil
          t.datetime :invitation_created_at, precision: nil
          t.datetime :invitation_sent_at, precision: nil
          t.integer :invitation_limit
          t.integer :invitations_count, default: 0
          t.string :invited_by_type
          t.bigint :invited_by_id
          t.string :invitation_token
          t.index ["confirmation_token"], name: "index_staff_on_confirmation_token", unique: true
          t.index ["email"], name: "index_staff_on_email", unique: true
          t.index ["invitation_token"], name: "index_staff_on_invitation_token", unique: true
          t.index ["invited_by_id"], name: "index_staff_on_invited_by_id"
          t.index ["invited_by_type", "invited_by_id"], name: "index_staff_on_invited_by"
          t.index ["reset_password_token"], name: "index_staff_on_reset_password_token", unique: true
          t.index ["unlock_token"], name: "index_staff_on_unlock_token", unique: true
        end
      end
    end
  end
end
