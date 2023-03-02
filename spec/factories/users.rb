FactoryBot.define do
  factory :user do
    sequence :email do |n|
      "user_#{n}@example.com"
    end
    name { "John Smith" }
    trn { "1234567" }
    date_of_birth { Date.new(2000, 1, 1) }
  end
end
