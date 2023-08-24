# frozen_string_literal: true
module HostingEnvironment
  TEST_ENVIRONMENTS = %w[local dev test preprod review].freeze
  PRODUCTION_URL = I18n.t("service.url")

  def self.host
    ENV.fetch("HOSTING_DOMAIN")
  end

  def self.aytq_domain
    host
  end

  def self.check_records_domain
    ENV.fetch("CHECK_RECORDS_DOMAIN")
  end

  def self.environment_name
    ENV.fetch("HOSTING_ENVIRONMENT_NAME", "unknown-environment")
  end

  def self.review?
    environment_name == "review"
  end

  def self.test_environment?
    TEST_ENVIRONMENTS.include?(HostingEnvironment.environment_name)
  end

  def self.production?
    environment_name == "production"
  end
end
