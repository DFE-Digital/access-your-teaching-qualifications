# frozen_string_literal: true

namespace :check_records, path: "check-records" do
  get "/sign-in", to: "sign_in#new"
  get "/sign-out", to: "sign_out#new"

  get "/auth/dfe/callback", to: "omniauth_callbacks#dfe"
  post "/auth/developer/callback" => "omniauth_callbacks#dfe_bypass"

  get "/start", to: "pages#start"
  get "/search", to: "search#new"
  get "/result", to: "search#result"
end

root to: redirect("/check-records/start"), as: :check_records_root
