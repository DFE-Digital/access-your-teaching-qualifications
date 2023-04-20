# frozen_string_literal: true

namespace :check_records, path: "check-records" do
  root to: "sign_in#new"

  get "/sign-in", to: "sign_in#new"

  post "/auth/developer/callback" => "omniauth_callbacks#dfe_bypass"
end
