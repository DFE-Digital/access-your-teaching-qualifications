Rails.application.routes.draw do
  devise_for :staff

  root to: "pages#home"

  namespace :support_interface, path: "/support" do
    get "/", to: "support_interface#index"

    mount FeatureFlags::Engine => "/features"
  end

  get "/accessibility", to: "static#accessibility"
  get "/cookies", to: "static#cookies"
  get "/privacy", to: "static#privacy"
end
