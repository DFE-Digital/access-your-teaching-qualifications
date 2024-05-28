class ClearOneLogingVerifiedNameField < ActiveRecord::Migration[7.1]
  def change
    User.update_all(one_login_verified_name: nil)
  end
end
