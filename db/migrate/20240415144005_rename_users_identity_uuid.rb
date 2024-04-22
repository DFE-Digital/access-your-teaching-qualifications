class RenameUsersIdentityUuid < ActiveRecord::Migration[7.1]
  def change
    reversible do |dir|
      dir.up do
        change_column :users, :identity_uuid, :string
      end
    end
    rename_column :users, :identity_uuid, :auth_uuid
    add_column :users, :auth_provider, :string
  end
end
