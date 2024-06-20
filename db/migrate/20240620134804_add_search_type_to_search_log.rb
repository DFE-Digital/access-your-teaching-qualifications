class AddSearchTypeToSearchLog < ActiveRecord::Migration[7.1]
  def change
    add_column :search_logs, :search_type, :string
  end
end
