FactoryBot.define do
  factory :feedback do
    sequence(:email) { |n| "someone-#{n}@example.com" }
    satisfaction_rating { "very_satisfied" }
    improvement_suggestion { "I would like to see more of this" }
    service { "check" }
    contact_permission_given { true }
  end
end
