require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
require "rails/test_unit/railtie"
require "./app/models/hosting_environment"
require "grover"
require "ostruct"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module AccessYourTeachingQualifications
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Keys are now derived with SHA-256, the Rails 7.1 default. Columns written
    # before that change are carried by the setting below, which registers a
    # SHA-1 previous scheme for the non-deterministic columns so they still
    # decrypt. It sits under `load_defaults` so it survives the version walk.
    #
    # It comes out once `rails pii:verify` reports no unreadable rows in
    # production, which is what `rails pii:re_encrypt` is for. Tracked at
    # https://github.com/DFE-Digital/teaching-record-team-project-board/issues/455
    config.active_record.encryption.support_sha1_for_non_deterministic_encryption = true

    # Rails 7.1 defaults this to false, which drops the autoload paths from
    # $LOAD_PATH. Several initializers, and `app/lib/dfe_sign_in.rb` itself,
    # `require` files that live under those paths, so turning it off breaks
    # boot. Reworking them to rely on autoloading is a separate piece of work:
    # the `DfE` acronym inflection is registered in an initializer, which runs
    # after the autoloader has already scanned and named the constants.
    config.add_autoload_paths_to_load_path = true

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    config.time_zone = "London"

    config.assets.paths << Rails.root.join("node_modules/govuk-frontend/dist/govuk/assets/images")
    config.assets.paths << Rails.root.join("node_modules/govuk-frontend/dist/govuk/assets/fonts")

    config.action_mailer.notify_settings = {
      api_key:
        ENV.fetch("GOVUK_NOTIFY_API_KEY") do
          raise "'GOVUK_NOTIFY_API_KEY' should be configured in " \
                  ".env.*environment* file. Please refer to " \
                  "https://github.com/DFE-Digital/access-your-teaching-qualifications/#notify"
        end
    }

    config.active_job.queue_adapter = :sidekiq

    config.audits1984 = {
      auditor_class: "Staff",
      base_controller_class: "SupportInterface::SupportInterfaceController"
    }
    config.console1984 = { ask_for_username_if_empty: true }

    config.exceptions_app = routes
    config.middleware.use Grover::Middleware
  end
end
