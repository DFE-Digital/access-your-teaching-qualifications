class AddNotNullConstraintToRolesInternal < ActiveRecord::Migration[7.1]
  def change
    change_column_null :roles, :internal, false
  end
end
