class CreateOrganisations < ActiveRecord::Migration[7.0]
  def change
    create_table :organisations do |t|
      t.string :company_registration_number

      t.timestamps
    end
    add_index :organisations, :company_registration_number, unique: true
  end
end
