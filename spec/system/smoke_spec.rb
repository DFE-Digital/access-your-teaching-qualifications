# frozen_string_literal: true
require "spec_helper"
require "capybara/rspec"
require "capybara/cuprite"
require "pry-nav"

Capybara.javascript_driver = :cuprite

TEST_ENVIRONMENTS = "local dev test preprod review"

# If developing these tests locally, run them by:
# - sourcing the env vars in .env.development
# - running bin/smoke

RSpec.describe "Smoke test", type: :system, js: true, smoke_test: true do
  describe "Access your teaching qualifications" do
    before do
      Capybara.app_host = ENV["HOSTING_DOMAIN"]
    end

    it "AYTQ works as expected" do
      when_i_visit_the_aytq_service
      then_i_see_the_aytq_service
    end

    it "/health/all returns 200" do
      when_i_visit_the_aytq_service(endpoint: "/health/all")
      puts "HEALTHCHECK:"
      puts page.text
      expect(page.status_code).to eq(200)
    end
  end

  describe "Check a teacher’s record" do
    before do
      Capybara.app_host = ENV["CHECK_RECORDS_DOMAIN"]
    end

    it "Check works as expected" do
      when_i_visit_the_check_service
      then_i_see_the_check_service
    end
  end

  private

  def when_i_visit_the_aytq_service(endpoint: "")
    username = ENV["SUPPORT_USERNAME"]
    password = ENV["SUPPORT_PASSWORD"]
    page.driver.basic_authorize(username, password)
    page.visit(ENV["HOSTING_DOMAIN"] + endpoint)
  end

  def when_i_visit_the_check_service
    username = ENV["SUPPORT_USERNAME"]
    password = ENV["SUPPORT_PASSWORD"]
    page.driver.basic_authorize(username, password)
    page.visit(ENV["CHECK_RECORDS_DOMAIN"])
  end

  def then_i_see_the_check_service
    expect(page).to have_content "Check a teacher’s record"
    expect(page).to have_content "Sign in"
  end

  def then_i_see_the_aytq_service
    expect(page).to have_content "Access your teaching qualifications"
    expect(page).to have_content "Sign in"
  end
end
