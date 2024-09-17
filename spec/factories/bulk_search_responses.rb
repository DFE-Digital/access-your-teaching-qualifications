FactoryBot.define do
  factory :bulk_search_response do
    association :dsi_user
    body { { results: [], not_found: [] } }
    total { 0 }
    expires_at { 30.minutes.from_now }
  end
end
