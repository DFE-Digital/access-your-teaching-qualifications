require "sidekiq/web"
require "route_constraints/access_your_teaching_qualifications_constraint"
require "route_constraints/check_records_constraint"

Rails.application.routes.draw do
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

  constraints(RouteConstraints::AccessYourTeachingQualificationsConstraint.new) { draw(:aytq) }
  constraints(RouteConstraints::CheckRecordsConstraint.new) { draw(:check_records) }
end
