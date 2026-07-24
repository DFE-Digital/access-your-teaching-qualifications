class AddUniqueIndexOnAuthProviderAndAuthUuidToUsers < ActiveRecord::Migration[7.2]
  def change
    add_index :users, %i[auth_provider auth_uuid], unique: true
  end
end
