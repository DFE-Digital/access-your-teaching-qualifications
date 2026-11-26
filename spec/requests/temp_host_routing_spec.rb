require "rails_helper"

# The maintenance tooling fronts the public hosts with a static maintenance page
# and creates a "temp" ingress so an operator can still reach the application to
# smoke test it (see maintenance_page/manifests). Outside production those hosts
# carry the environment name, so the route constraints have to match it: when
# they do not, no routes are drawn for the host and every path 404s.
RSpec.describe "Temp host routing", type: :request do
  aytq_temp_hosts = %w[
    access-your-teaching-qualifications-temp.teacherservices.cloud
    access-your-teaching-qualifications-temp.test.teacherservices.cloud
    access-your-teaching-qualifications-test-temp.test.teacherservices.cloud
    access-your-teaching-qualifications-preprod-temp.test.teacherservices.cloud
  ]

  check_records_temp_hosts = %w[
    check-a-teachers-record-temp.teacherservices.cloud
    check-a-teachers-record-temp.test.teacherservices.cloud
    check-a-teachers-record-test-temp.test.teacherservices.cloud
    check-a-teachers-record-preprod-temp.test.teacherservices.cloud
  ]

  unrelated_hosts = %w[example.com teacherservices.cloud]

  def get_with_host(path, host)
    get path,
        headers: {
          "HOST" => host,
          "HTTP_AUTHORIZATION" =>
            ActionController::HttpAuthentication::Basic.encode_credentials(
              ENV.fetch("SUPPORT_USERNAME", "test"),
              ENV.fetch("SUPPORT_PASSWORD", "test")
            )
        }
  end

  describe "Access your teaching qualifications" do
    aytq_temp_hosts.each do |host|
      it "serves the qualifications pages on #{host}" do
        get_with_host "/qualifications/accessibility", host

        expect(response).to have_http_status(:ok)
      end
    end

    (check_records_temp_hosts + unrelated_hosts).each do |host|
      it "does not serve the qualifications pages on #{host}" do
        get_with_host "/qualifications/accessibility", host

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "Check a teacher’s record" do
    check_records_temp_hosts.each do |host|
      it "serves the check records pages on #{host}" do
        get_with_host "/check-records/accessibility", host

        expect(response).to have_http_status(:ok)
      end
    end

    (aytq_temp_hosts + unrelated_hosts).each do |host|
      it "does not serve the check records pages on #{host}" do
        get_with_host "/check-records/accessibility", host

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
