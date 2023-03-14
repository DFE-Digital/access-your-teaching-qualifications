class User < ApplicationRecord
  devise :omniauthable

  def self.from_identity(auth_data)
    email = auth_data.info.email
    user = find_or_initialize_by(email:)
    user.assign_attributes(
      date_of_birth: auth_data.info.date_of_birth,
      family_name: auth_data.info.family_name,
      given_name: auth_data.info.given_name,
      name: auth_data.info.name,
      trn: auth_data.info.trn
    )
    user.tap(&:save!)
  end

  def induction
    Struct.new(:name, :status, :completed_at).new(
      "Induction",
      :pass,
      Date.new(2015, 11, 1)
    )
  end

  def name
    ::NameOfPerson::PersonName.full(self[:name])
  end
end
