class Organisation < ApplicationRecord
  validates :company_registration_number, presence: true, uniqueness: { case_sensitive: false }
end
