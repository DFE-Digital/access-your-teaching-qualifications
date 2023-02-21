class AddDeviseInvitableToStaff < ActiveRecord::Migration[7.0]
  def change
    change_table :staff, bulk: true do |t|
      t.datetime :invitation_accepted_at
      t.datetime :invitation_created_at
      t.datetime :invitation_sent_at
      t.integer :invitation_limit
      t.integer :invitations_count, default: 0
      t.references :invited_by, polymorphic: true
      t.string :invitation_token

      t.index :invitation_token, unique: true
      t.index :invited_by_id
    end
  end
end
