class CreateSearchLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :search_logs do |t|
      t.references :dsi_user, foreign_key: true
      t.string :last_name
      t.date :date_of_birth
      t.timestamps
    end
  end
end
