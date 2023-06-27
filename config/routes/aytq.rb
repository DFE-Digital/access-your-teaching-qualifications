# frozen_string_literal: true

namespace :qualifications do
  get "/accessibility", to: "static#accessibility"
  get "/cookies", to: "static#cookies"
  get "/privacy", to: "static#privacy"

  get "/users/auth/identity/callback", to: "users/omniauth_callbacks#identity"
  get "/sign-in", to: "users/sign_in#new"
  get "/sign-out", to: "users/sign_out#new"

  resource :start, only: [:show]

  devise_scope :user do
    resources :certificates, only: [:show]
    resource :identity_user, only: [:show]
    resource :npq_certificate, only: [:show]

    root to: "qualifications#show", as: :dashboard
  end
end

root to: redirect("/qualifications/start"), as: :qualifications_root
