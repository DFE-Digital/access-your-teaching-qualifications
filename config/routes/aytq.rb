# frozen_string_literal: true

namespace :qualifications do
  get "/accessibility", to: "static#accessibility"
  get "/cookies", to: "static#cookies"

  get "/users/auth/identity/callback", to: "users/omniauth_callbacks#complete"
  get "/users/auth/onelogin/callback", to: "users/omniauth_callbacks#complete"
  get "/sign-in", to: "users/sign_in#new"
  get "/sign-out/new", to: "users/sign_out#new", as: :new_sign_out
  post "/sign-out/confirm", to: "users/sign_out#create", as: :confirm_sign_out
  get "/sign-out", to: "users/sign_out#complete"

  get "/users/auth/identity/logout", to: "users/sign_out#complete"

  resource :start, only: [:show]

  resources :certificates, only: [:show]
  resource :identity_user, only: [:show]
  resource :one_login_user, only: [:show], path: "one-login-user" do
    resources :name_changes,
      only: [:new, :create, :show, :edit, :update],
      path: "name-changes",
      module: "one_login_users" do
      post "/confirm", on: :member, to: "name_changes#confirm"
      get "/submitted", on: :member, to: "name_changes#submitted"
    end
  end
  resource :npq_certificate, only: [:show]

  root to: "qualifications#show", as: :dashboard

  scope "/feedback" do
    get "/", to: "feedbacks#new", as: :feedbacks
    post "/", to: "feedbacks#create"
    get "/success", to: "feedbacks#success"
  end
end

scope via: :all do
  get '/404', to: 'qualifications/errors#not_found'
  get '/422', to: 'qualifications/errors#unprocessable_entity'
  get '/500', to: 'qualifications/errors#internal_server_error'
end

root to: redirect("/qualifications/sign-in"), as: :qualifications_root
