class Role < ApplicationRecord
  validates :code, uniqueness: { case_sensitive: false }
end
