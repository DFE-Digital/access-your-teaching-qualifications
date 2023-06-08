# frozen_string_literal: true

namespace :check_records, path: "check-records" do
  get "/sign-in", to: "sign_in#new"
  get "/sign-out", to: "sign_out#new"

  get "/auth/dfe/callback", to: "omniauth_callbacks#dfe"
  post "/auth/developer/callback" => "omniauth_callbacks#dfe_bypass"

  get "/search", to: "search#new"
  get "/result", to: "search#show"

  resources :teachers, only: %i[show]
end

root to: redirect("/check-records/search"), as: :check_records_root
