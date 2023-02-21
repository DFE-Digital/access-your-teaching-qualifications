class Staff < ApplicationRecord
  devise(
    :confirmable,
    :database_authenticatable,
    :invitable,
    :lockable,
    :recoverable,
    :rememberable,
    :timeoutable,
    :trackable,
    :validatable
  )
end
