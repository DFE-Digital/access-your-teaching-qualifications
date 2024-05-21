class CreateDateOfBirthChanges < ActiveRecord::Migration[7.1]
  def change
    create_table :date_of_birth_changes do |t|
      t.references :user, null: false, foreign_key: true
      t.date :date_of_birth

      t.timestamps
    end
  end
end
