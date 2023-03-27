class ChangeLengthOfSensitiveFieldsUser < ActiveRecord::Migration[7.0]
  def up
    change_table :users, bulk: true do |t|
      t.change :email, :string, limit: 510
      t.change :family_name, :string, limit: 510
      t.change :given_name, :string, limit: 510
    end
  end

  def down
    change_table :users, bulk: true do |t|
      t.change :email, :string, limit: 255
      t.change :family_name, :string, limit: 255
      t.change :given_name, :string, limit: 255
    end
  end
end
