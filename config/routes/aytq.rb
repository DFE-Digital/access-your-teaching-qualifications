# frozen_string_literal: true

root to: "users/sign_in#new"

devise_for :users,
           controllers: {
             omniauth_callbacks: "users/omniauth_callbacks"
           }
get "/sign-in", to: "users/sign_in#new"
get "/sign-out", to: "users/sign_out#new"

devise_scope :user do
  resources :certificates, only: [:show]
  resource :identity_user, only: [:show]
  resource :npq_certificate, only: [:show]
  resource :qualifications, only: [:show]
end

get "/accessibility", to: "static#accessibility"
get "/cookies", to: "static#cookies"
get "/privacy", to: "static#privacy"
