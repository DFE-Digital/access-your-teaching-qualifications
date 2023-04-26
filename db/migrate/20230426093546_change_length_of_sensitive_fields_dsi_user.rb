class ChangeLengthOfSensitiveFieldsDsiUser < ActiveRecord::Migration[7.0]
  def up
    change_table :dsi_users, bulk: true do |t|
      t.change :email, :string, limit: 510
      t.change :first_name, :string, limit: 510
      t.change :last_name, :string, limit: 510
    end
  end

  def down
    change_table :dsi_users, bulk: true do |t|
      t.change :email, :string, limit: 255
      t.change :first_name, :string, limit: 255
      t.change :last_name, :string, limit: 255
    end
  end
end
