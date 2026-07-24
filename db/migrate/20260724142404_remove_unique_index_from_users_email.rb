class RemoveUniqueIndexFromUsersEmail < ActiveRecord::Migration[7.2]
  def up
    remove_index :users, :email, name: "index_users_on_email"
    add_index :users, :email, name: "index_users_on_email"
  end

  def down
    remove_index :users, :email, name: "index_users_on_email"
    add_index :users, :email, unique: true, name: "index_users_on_email"
  end
end
