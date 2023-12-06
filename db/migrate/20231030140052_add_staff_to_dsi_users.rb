class AddStaffToDsiUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :dsi_users, :staff, :boolean, default: false, null: false
  end
end
