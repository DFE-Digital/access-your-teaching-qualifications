module CheckRecords
  module AuthenticationSteps
    def when_i_sign_in_via_dsi(authorised: true)
      given_dsi_auth_is_mocked(authorised:)
      when_i_visit_the_sign_in_page
      and_click_the_dsi_sign_in_button
    end
    alias_method :and_i_am_signed_in_via_dsi, :when_i_sign_in_via_dsi

    def given_dsi_auth_is_mocked(authorised:)
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
              }
            }
          }
        }
      )

      stub_request(
        :get,
        "#{ENV.fetch("DFE_SIGN_IN_API_BASE_URL")}/services/checkrecordteacher/organisations/#{org_id}/users/123456",
      ).to_return_json(
        status: 200,
        body: { "roles" => [{ "code" => (authorised ? role_code : "Unauthorised_Role") }] },
      )
    end

    def when_i_visit_the_sign_in_page
      visit check_records_sign_in_path
    end

    def and_click_the_dsi_sign_in_button
      click_button "Sign in"
    end

    def org_id
      "12345678-1234-1234-1234-123456789012"
    end

    def role_code
      ENV.fetch("DFE_SIGN_IN_API_ROLE_CODES").split(",").first
    end
  end
end
