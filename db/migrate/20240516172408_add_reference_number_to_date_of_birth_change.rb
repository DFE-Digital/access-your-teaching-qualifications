class AddReferenceNumberToDateOfBirthChange < ActiveRecord::Migration[7.1]
  def change
    add_column :date_of_birth_changes, :reference_number, :string
  end
end
