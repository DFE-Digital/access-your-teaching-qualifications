class User < ApplicationRecord
  devise :omniauthable

  def self.from_identity(auth_data)
    email = auth_data.info.email
    user = find_or_initialize_by(email:)
    user.assign_attributes(
      name: auth_data.info.name,
      given_name: auth_data.info.given_name,
      family_name: auth_data.info.family_name,
      trn: auth_data.info.trn,
      date_of_birth: auth_data.info.date_of_birth
    )
    user.tap(&:save!)
  end
end
