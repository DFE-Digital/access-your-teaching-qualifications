class CreateBulkSearchResponses < ActiveRecord::Migration[7.2]
  def change
    create_table :bulk_search_responses, id: :uuid do |t|
      t.jsonb :body
      t.datetime :expires_at
      t.references :dsi_user, null: false, foreign_key: true
      t.integer :total

      t.timestamps
    end
  end
end
