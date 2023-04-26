module CheckRecords
  module AuthenticationSteps
    def when_i_sign_in_via_dsi
      given_dsi_auth_is_mocked
      when_i_visit_the_sign_in_page
      and_click_the_dsi_sign_in_button
    end

    def given_dsi_auth_is_mocked
      OmniAuth.config.mock_auth[:dfe] = OmniAuth::AuthHash.new(
        {
          provider: "dfe",
          info: {
            email: "test@example.com",
            first_name: "Test",
            last_name: "User",
            uid: "123456"
          }
        }
      )
    end

    def when_i_visit_the_sign_in_page
      visit check_records_sign_in_path
    end

    def and_click_the_dsi_sign_in_button
      click_button "Sign in with DSI"
    end
  end
end
