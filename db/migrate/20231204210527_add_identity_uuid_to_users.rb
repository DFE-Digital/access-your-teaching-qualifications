class AddIdentityUuidToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :identity_uuid, :uuid
  end
end
