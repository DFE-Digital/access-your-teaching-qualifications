class User < ApplicationRecord
  encrypts :email, deterministic: true
  encrypts :family_name, :given_name, :name

  def self.from_identity(auth_data)
    email = auth_data.info.email
    user = find_or_initialize_by(email:)
    user.assign_attributes(
      date_of_birth: auth_data.extra.raw_info.birthdate,
      family_name: auth_data.info.last_name,
      given_name: auth_data.info.first_name,
      name: auth_data.info.name,
      trn: auth_data.extra.raw_info.trn,
      identity_uuid: auth_data.uid
    )
    user.tap(&:save!)
  end

  def name
    ::NameOfPerson::PersonName.full(self[:name])
  end
end
