class AddOneLoginVerifiedFieldsToUser < ActiveRecord::Migration[7.1]
  def change
    change_table :users, bulk: true do |t|
      t.string :one_login_verified_name
      t.date :one_login_verified_birth_date
    end
  end
end
