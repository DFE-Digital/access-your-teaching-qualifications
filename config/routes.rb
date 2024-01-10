require "sidekiq/web"
require "route_constraints/access_your_teaching_qualifications_constraint"
require "route_constraints/check_records_constraint"

Rails.application.routes.draw do
  namespace :support_interface, path: "/support" do
    get "/", to: "support_interface#index"
    root to: "support_interface#index"

    get "/sign-in", to: "sign_in#new"
    get "/not-authorised", to: "sign_in#not_authorised"
    get "/sign-out", to: "sign_out#new"

    get "/auth/staff/sign-out", to: "sign_out#new", as: :dsi_sign_out

    get "/auth/staff/callback", to: "omniauth_callbacks#staff"
    post "/auth/developer/callback" => "omniauth_callbacks#staff_bypass"

    resources :feedback, only: %i[index]
    resources :staff, only: %i[index]

    mount FeatureFlags::Engine => "/features"
    mount Audits1984::Engine => "/console"
  end

  constraints(RouteConstraints::AccessYourTeachingQualificationsConstraint.new) { draw(:aytq) }
  constraints(RouteConstraints::CheckRecordsConstraint.new) { draw(:check_records) }
end
