source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.1"

gem "bootsnap", require: false
gem "cssbundling-rails"
gem "devise"
gem "devise_invitable"
gem "govuk-components"
gem "govuk_design_system_formbuilder"
gem "govuk_feature_flags",
    git: "https://github.com/DFE-Digital/govuk_feature_flags.git",
    tag: "v1.0.1"
gem "govuk_markdown"
gem "jsbundling-rails"
gem "omniauth-oauth2", "~> 1.8"
gem "omniauth-rails_csrf_protection"
gem "pg", "~> 1.1"
gem "propshaft"
gem "puma", "~> 6.1"
gem "rails", "~> 7.0.4", ">= 7.0.4.2"
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]

group :development, :test do
  gem "debug", platforms: %i[mri mingw x64_mingw]
  gem "dotenv-rails"
end

group :development do
  gem "prettier_print", require: false
  gem "rladr"
  gem "rubocop-govuk", require: false
  gem "solargraph", require: false
  gem "solargraph-rails", require: false
  gem "syntax_tree", require: false
  gem "syntax_tree-haml", require: false
  gem "syntax_tree-rbs", require: false
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "cuprite"
  gem "factory_bot_rails"
  gem "shoulda-matchers"
end

group :test, :development do
  gem "rspec"
  gem "rspec-rails"
end
