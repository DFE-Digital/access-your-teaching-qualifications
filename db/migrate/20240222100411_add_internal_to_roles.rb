class AddInternalToRoles < ActiveRecord::Migration[7.1]
  def change
    add_column :roles, :internal, :boolean, default: false
  end
end
