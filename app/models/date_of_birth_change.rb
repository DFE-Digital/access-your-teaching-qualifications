class DateOfBirthChange < ApplicationRecord
  belongs_to :user
  has_one_attached :evidence
end
