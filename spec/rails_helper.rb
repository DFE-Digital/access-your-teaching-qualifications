# This file is copied to spec/ when you run 'rails generate rspec:install'
require "spec_helper"
ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "rspec/rails"
# Add additional requires below this line. Rails is not loaded until this point!

require "capybara/rspec"
require "capybara/cuprite"
require "sidekiq/testing"
require "webmock/rspec"
require "dfe/analytics/testing"
require "dfe/analytics/rspec/matchers"

WebMock.disable_net_connect!(allow_localhost: true)

Capybara.register_driver(:cuprite) do |app|
  Capybara::Cuprite::Driver.new(app, timeout: 200, process_timeout: 120, window_size: [1200, 800])
end
Capybara.default_driver = :cuprite
Capybara.javascript_driver = :cuprite
Capybara.app_host = "http://qualifications.localhost"

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
Dir[Rails.root.join("spec/support/**/*.rb")].sort.each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end
RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = Rails.root.join("spec/fixtures")

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # You can uncomment this line to turn off ActiveRecord support entirely.
  # config.use_active_record = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, type: :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
  config.before(:each, type: :system) { driven_by(:cuprite) }
  config.before { Sidekiq::Worker.clear_all }
  config.before(:each) do
    stub_request(:any, /npq-registration-sandbox-web.teacherservices/).to_rack(FakeNpqQualificationsApi)
  end
  config.before(:each, test: :with_fake_quals_api) do
    stub_request(:any, /preprod-teacher-qualifications-api/).to_rack(FakeQualificationsApi)
  end
  config.around(:each, test: :with_stubbed_auth) do |example|
    OmniAuth.config.test_mode = true
    example.run
    OmniAuth.config.test_mode = false

    OmniAuth.config.mock_auth.delete(:identity)
    OmniAuth.config.mock_auth.delete(:dfe)
  end

  config.around(:each, host: :check_records) do |example|
    Capybara.app_host = "http://check_records.localhost"
    example.run
    Capybara.app_host = "http://qualifications.localhost"
  end

  config.include ActiveJob::TestHelper
  config.include ActiveSupport::Testing::TimeHelpers
  config.include FakeQualificationsData, test: :with_fake_quals_data
  config.include ViewComponent::TestHelpers, type: :component
end
