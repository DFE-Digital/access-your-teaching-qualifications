class AddNameColumnsToNameChanges < ActiveRecord::Migration[7.1]
  def change
    change_table :name_changes, bulk: true do |t|
      t.string :first_name
      t.string :middle_name
      t.string :last_name
    end
  end
end
