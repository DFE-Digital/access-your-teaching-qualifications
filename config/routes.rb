Rails.application.routes.draw do
  root to: "pages#home"

  namespace :support_interface, path: "/support" do
    get "/", to: "support_interface#index"
  end
end
