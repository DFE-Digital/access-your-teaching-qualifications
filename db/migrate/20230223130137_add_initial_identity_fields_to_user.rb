class AddInitialIdentityFieldsToUser < ActiveRecord::Migration[7.0]
  def change
    change_table :users, bulk: true do |t|
      t.string :name
      t.string :given_name
      t.string :family_name
      t.string :trn
      t.date :date_of_birth
    end
  end
end
