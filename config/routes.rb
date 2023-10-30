require "sidekiq/web"
require "route_constraints/access_your_teaching_qualifications_constraint"
require "route_constraints/check_records_constraint"

Rails.application.routes.draw do
  namespace :support_interface, path: "/support" do
    get "/", to: "support_interface#index"
    root to: "support_interface#index", as: :staff_root

    resources :staff, only: %i[index]

    mount FeatureFlags::Engine => "/features"
    mount Audits1984::Engine => "/console"
  end

  constraints(RouteConstraints::AccessYourTeachingQualificationsConstraint.new) { draw(:aytq) }
  constraints(RouteConstraints::CheckRecordsConstraint.new) { draw(:check_records) }
end
