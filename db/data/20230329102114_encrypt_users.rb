# frozen_string_literal: true

class EncryptUsers < ActiveRecord::Migration[7.0]
  def up
    User.find_each(&:encrypt)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
