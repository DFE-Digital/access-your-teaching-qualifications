class RemoveStaffFromDsiUsers < ActiveRecord::Migration[7.1]
  def change
    remove_column :dsi_users, :staff, :boolean
  end
end
