FactoryBot.define do
  factory :bulk_search_log do
    dsi_user { nil }
    query_count { 1 }
    result_count { 1 }
    csv { "MyText" }
  end
end
