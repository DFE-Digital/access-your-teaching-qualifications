class CreateBulkSearchLogs < ActiveRecord::Migration[7.2]
  def change
    create_table :bulk_search_logs do |t|
      t.references :dsi_user, null: false, foreign_key: true
      t.integer :query_count
      t.integer :result_count
      t.text :csv

      t.timestamps
    end
  end
end
