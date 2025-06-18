source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.3.0"

gem "activerecord-session_store"
gem "amazing_print"
gem "audits1984"
gem "azure-storage-blob", github: "honeyankit/azure-storage-ruby"
gem "bootsnap", require: false
gem "console1984"
gem "cssbundling-rails"
gem "data_migrate", github: "ilyakatz/data-migrate"
gem "dfe-analytics", github: "DFE-Digital/dfe-analytics", tag: "v1.14.2"
gem "faraday"
gem "govuk-components", "~> 5.6"
gem "govuk_design_system_formbuilder", "~> 5.6"
gem "govuk_feature_flags",
    git: "https://github.com/DFE-Digital/govuk_feature_flags.git",
    tag: "v1.0.1"
gem "govuk_markdown"
gem "grover"
gem "hashie"
gem "jsbundling-rails"
gem "jwt"
gem "logstash-logger"
gem "mail-notify"
gem "name_of_person"
gem "okcomputer"
gem "omniauth-oauth2", "~> 1.8"
gem "omniauth_openid_connect"
gem "omniauth-rails_csrf_protection"
gem "pagy"
gem "pg", "~> 1.5"
gem "propshaft"
gem "puma", "~> 6.4"
gem "rails", "~> 7.2.0"
gem "rails_semantic_logger"
gem "repost"
gem "sentry-rails", "~> 5.19"
gem "sidekiq", "< 7" #7 requires Redis >6.2 which isn't available on Azure currently
gem "sidekiq-cron"
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]

group :development, :test do
  gem "dotenv-rails"
  gem "launchy"
  gem "pry-nav"
  gem "rspec"
  gem "rspec-rails"
  gem "sinatra"
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
  gem "webmock"
end
