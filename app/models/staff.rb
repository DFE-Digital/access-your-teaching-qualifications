class Staff < ApplicationRecord
  devise(
    :confirmable,
    :database_authenticatable,
    :lockable,
    :registerable,
    :recoverable,
    :rememberable,
    :timeoutable,
    :trackable,
    :validatable
  )
end
