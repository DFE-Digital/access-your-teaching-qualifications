FactoryBot.define do
  factory :dsi_user_session do
    dsi_user
    created_at { Time.zone.now }
    updated_at { Time.zone.now }
  end
end
