class AddResultCountToSearchLog < ActiveRecord::Migration[7.0]
  def change
    add_column :search_logs, :result_count, :integer
  end
end
