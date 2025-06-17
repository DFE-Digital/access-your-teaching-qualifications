# frozen_string_literal: true

namespace :check_records, path: "check-records" do
  get "/accessibility", to: "static#accessibility"
  get "/cookies", to: "static#cookies"

  get "/sign-in", to: "sign_in#new"
  get "/not-authorised", to: "sign_in#not_authorised"
  get "/sign-out", to: "sign_out#new"

  get "/auth/dfe/sign-out", to: "sign_out#new", as: :dsi_sign_out

  get "/auth/dfe/callback", to: "omniauth_callbacks#dfe"
  get "/auth/developer/callback" => "omniauth_callbacks#dfe_bypass"
  post "/auth/developer/callback" => "omniauth_callbacks#dfe_bypass"

  get "/search", to: "search#personal_details_search"
  get "/result", to: "search#personal_details_result"
  get "/trn-search", to: "search#trn_search"
  get "/trn-result", to: "search#trn_result"

  get "/terms-and-conditions", to: "terms_and_conditions#show"
  patch "/terms-and-conditions" => "terms_and_conditions#update"

  resources :teachers, only: %i[show]
  resources :bulk_searches, only: %i[new create show], path: 'bulk-searches'

  scope "/feedback" do
    get "/", to: "feedbacks#new", as: :feedbacks
    post "/", to: "feedbacks#create"
    get "/success", to: "feedbacks#success"
  end
end

scope via: :all do
  get '/404', to: 'check_records/errors#not_found'
  get '/422', to: 'check_records/errors#unprocessable_entity'
  get '/500', to: 'check_records/errors#internal_server_error'
end

root to: redirect("/check-records/search"), as: :check_records_root
