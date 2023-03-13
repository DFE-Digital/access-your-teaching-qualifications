require "sidekiq/web"

Rails.application.routes.draw do
  root to: "users/sign_in#new"

  devise_for :staff,
             controllers: {
               confirmations: "staff/confirmations",
               invitations: "staff/invitations",
               passwords: "staff/passwords",
               sessions: "staff/sessions",
               unlocks: "staff/unlocks"
             }

  devise_scope :staff do
    authenticate :staff do
      mount Sidekiq::Web, at: "sidekiq"
    end

    get "/staff/sign_out", to: "staff/sessions#destroy"
  end

  namespace :support_interface, path: "/support" do
    get "/", to: "support_interface#index"

    resources :staff, only: %i[index]

    mount FeatureFlags::Engine => "/features"
  end

  devise_for :users,
             controllers: {
               omniauth_callbacks: "users/omniauth_callbacks"
             }
  get "/sign-in", to: "users/sign_in#new"
  get "/sign-out", to: "users/sign_out#new"

  devise_scope :user do
    resource :identity_user, only: [:show]
    resource :qualifications, only: [:show]
    resource :qts_certificate, only: [:show]
  end

  get "/accessibility", to: "static#accessibility"
  get "/cookies", to: "static#cookies"
  get "/privacy", to: "static#privacy"
end
