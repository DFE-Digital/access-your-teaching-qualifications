module AuthenticationSteps
  def when_i_sign_in_via_dsi(authorised: true, internal: false, orgs: [organisation], accept_terms_and_conditions: true)
    given_dsi_auth_is_mocked(authorised:, internal:, orgs:,)
    when_i_visit_the_sign_in_page
    and_wait_for_the_page_to_load
    and_i_accept_the_terms_and_conditions(accept_terms_and_conditions)
    and_wait_for_the_page_to_load
  end
  alias_method :and_i_am_signed_in_via_dsi, :when_i_sign_in_via_dsi

  def when_i_sign_in_as_staff_via_dsi
    when_i_sign_in_via_dsi(authorised: true, internal: true, accept_terms_and_conditions: false)
  end
  alias_method :and_i_am_signed_in_as_staff_via_dsi, :when_i_sign_in_as_staff_via_dsi

  def given_dsi_auth_is_mocked(authorised: true, internal: false, orgs: [organisation])
    OmniAuth.config.mock_auth[:dfe] = OmniAuth::AuthHash.new(
      {
        provider: "dfe",
        uid: "123456",
        credentials: {
          id_token: "abc123",
        },
        info: {
          email: "test@example.com",
          first_name: "Test",
          last_name: "User"
        },
        extra: {
          raw_info: {
            organisation: {
              id: org_id,
              name: "Test Org",
            }
          }
        }
      }
    )

    stub_request(
      :get, organisations_endpoint
    ).to_return_json(
      status: 200,
      body: orgs,
    )

    stub_request(
      :get,
      "#{ENV.fetch("DFE_SIGN_IN_API_BASE_URL")}/services/checkrecordteacher/organisations/#{org_id}/users/123456",
    ).to_return_json(
      status: 200,
      body: { "roles" => [{ "code" => (authorised ? role_code(internal:) : "Unauthorised_Role") }] },
    )
  end

  def given_dsi_auth_is_mocked_with_a_failure(message)
    allow(Sentry).to receive(:capture_exception)
    OmniAuth.config.mock_auth[:dfe] = message.to_sym

    global_failure_handler = OmniAuth.config.on_failure

    local_failure_handler = proc do |env|
      env["omniauth.error"] = OmniAuth::Strategies::OpenIDConnect::CallbackError.new(error: message)
      env
    end
    OmniAuth.config.on_failure = global_failure_handler << local_failure_handler

    yield if block_given?

    OmniAuth.config.on_failure = global_failure_handler
  end

  def when_i_visit_the_sign_in_page
    visit check_records_sign_in_path
  end

  def org_id
    "12345678-1234-1234-1234-123456789012"
  end

  def role_code(internal: false)
    @role_code ||= internal ? create(:role, :enabled, :internal).code : create(:role, :enabled).code
  end

  def organisations_endpoint
    "#{ENV.fetch("DFE_SIGN_IN_API_BASE_URL")}/users/123456/organisations"
  end

  def organisation(status: "Open")
    {
      "id" => org_id,
      "name" => "Test School",
      "status" => { "id" => 1, "name" => status },
    }
  end

  def and_i_accept_the_terms_and_conditions(accept)
    if accept
      click_on "Accept"
    end
  end

  def and_wait_for_the_page_to_load
    page.driver.refresh
  end
end
