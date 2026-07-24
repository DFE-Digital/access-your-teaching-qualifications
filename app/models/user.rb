class User < ApplicationRecord
  class AuthMissingUidError < StandardError; end

  encrypts :email, deterministic: true
  encrypts :family_name, :given_name, :name
  encrypts :one_login_verified_name

  has_many :name_changes
  has_many :date_of_birth_changes

  def self.from_auth(auth_data)
    uid = auth_data.uid
    provider = auth_data.provider
    email = auth_data.info.email
    raise AuthMissingUidError, "Auth response is missing a uid" if uid.blank?

    # Select on the stable provider subject, never on the mutable email. Fall
    # back to an unclaimed (no uid/provider) row so pre-cutover accounts are
    # backfilled once. Email is set from the payload even when another row
    # already holds it: two subjects sharing an email are distinct accounts.
    user =
      find_by(auth_provider: provider, auth_uuid: uid) ||
      find_by(email:, auth_uuid: nil, auth_provider: nil) ||
      new

    user.assign_attributes(
      # TODO: review how much of this PII we need to persist. We may no longer
      # have a requirement for it.
      email:,
      date_of_birth: auth_data.extra.raw_info.birthdate,
      family_name: auth_data.info.last_name,
      given_name: auth_data.info.first_name,
      name: auth_data.info.name,
      trn: auth_data.extra.raw_info.trn,
      auth_uuid: uid,
      auth_provider: provider,
      one_login_verified_name: auth_data.extra.raw_info.onelogin_verified_names&.first&.join(" "),
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
