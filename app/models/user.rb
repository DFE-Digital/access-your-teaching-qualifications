class User < ApplicationRecord
  encrypts :email, deterministic: true
  encrypts :family_name, :given_name, :name

  has_many :name_changes

  def self.from_auth(auth_data)
    email = auth_data.info.email
    user = find_or_initialize_by(email:)

    user.assign_attributes(
      # TODO: review how much of this PII we need to persist. We may no longer
      # have a requirement for it.
      date_of_birth: auth_data.extra.raw_info.birthdate,
      family_name: auth_data.info.last_name,
      given_name: auth_data.info.first_name,
      name: auth_data.info.name,
      trn: auth_data.extra.raw_info.trn,
      auth_uuid: auth_data.uid,
      auth_provider: auth_data.provider,
      one_login_verified_name: auth_data.extra.raw_info.onelogin_verified_names&.first&.join(' '),
      one_login_verified_birth_date: auth_data.extra.raw_info.onelogin_verified_birthdates&.first
    )
    user.tap(&:save!)
  end

  def name
    ::NameOfPerson::PersonName.full(self[:name])
  end

  def verified_by_one_login?
    one_login_verified_name.present? && one_login_verified_birth_date.present?
  end
end
