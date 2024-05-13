class AddCaseNumberToNameChange < ActiveRecord::Migration[7.1]
  def change
    add_column :name_changes, :reference_number, :string
  end
end
