class RemoveUniqueIndexFromDsiUsersEmail < ActiveRecord::Migration[7.2]
  def up
    remove_index :dsi_users, :email, name: "index_dsi_users_on_email"
  end

  def down
    add_index :dsi_users, :email, unique: true, name: "index_dsi_users_on_email"
  end
end
