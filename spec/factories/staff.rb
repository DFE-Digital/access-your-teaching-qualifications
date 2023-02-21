FactoryBot.define do
  factory :staff do
    email { "staff@example.com" }
    password { "password" }

    trait :confirmed do
      confirmed_at { Time.current }
    end
  end
end
