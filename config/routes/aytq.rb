# frozen_string_literal: true

namespace :qualifications do
  get "/accessibility", to: "static#accessibility"
  get "/cookies", to: "static#cookies"

  get "/users/auth/identity/callback", to: "users/omniauth_callbacks#identity"
  get "/sign-in", to: "users/sign_in#new"
  get "/sign-out", to: "users/sign_out#new"
  get "/users/auth/identity/logout", to: "users/sign_out#new"

  resource :start, only: [:show]

  resources :certificates, only: [:show]
  resource :identity_user, only: [:show]
  resource :npq_certificate, only: [:show]

  root to: "qualifications#show", as: :dashboard
end

scope via: :all do
  get '/404', to: 'qualifications/errors#not_found'
  get '/422', to: 'qualifications/errors#unprocessable_entity'
  get '/500', to: 'qualifications/errors#internal_server_error'
end

root to: redirect("/qualifications/sign-in"), as: :qualifications_root
