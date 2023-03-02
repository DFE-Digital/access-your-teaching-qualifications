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

  def induction
    Struct.new(:name, :status, :completed_at).new(
      "Induction",
      :pass,
      Date.new(2015, 11, 1)
    )
  end

  def itt
    Struct.new(
      :name,
      :qualification_name,
      :provider_name,
      :training_type,
      :subjects,
      :start_date,
      :end_date,
      :result,
      :age_range
    ).new(
      "Initial teacher training (ITT)",
      "Postgraduate Certificate in Education (PGCE)",
      "West London University",
      "HEI",
      %w[English Maths],
      Date.new(2015, 10, 1),
      Date.new(2018, 6, 23),
      :pass,
      "7 to 18 years"
    )
  end

  def name
    ::NameOfPerson::PersonName.full(self[:name])
  end

  def qts
    Struct.new(:name, :status, :awarded_at).new(
      "Qualified teacher status (QTS)",
      :awarded,
      Date.new(2014, 9, 1)
    )
  end
end
