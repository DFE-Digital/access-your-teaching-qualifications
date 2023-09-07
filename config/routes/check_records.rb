# frozen_string_literal: true

namespace :check_records, path: "check-records" do
  get "/accessibility", to: "static#accessibility"
  get "/cookies", to: "static#cookies"
  get "/privacy", to: "static#privacy"

  get "/sign-in", to: "sign_in#new"
  get "/not-authorised", to: "sign_in#not_authorised"
  get "/sign-out", to: "sign_out#new"

  get "/auth/dfe/callback", to: "omniauth_callbacks#dfe"
  post "/auth/developer/callback" => "omniauth_callbacks#dfe_bypass"

  get "/search", to: "search#new"
  get "/result", to: "search#show"

  resources :teachers, only: %i[show]

  scope "/feedback" do
    get "/", to: "feedbacks#new", as: :feedbacks
    post "/", to: "feedbacks#create"
    get "/success", to: "feedbacks#success"
  end
end

root to: redirect("/check-records/search"), as: :check_records_root
