module AuthenticationSteps
  def and_i_am_signed_in
    @user = create(:user)
    sign_in(@user)
  end

  def and_i_am_signed_in_via_identity
    given_identity_auth_is_mocked
    when_i_go_to_the_sign_in_page
    and_click_the_sign_in_button
  end

  def given_identity_auth_is_mocked
    OmniAuth.config.mock_auth[:identity] = OmniAuth::AuthHash.new(
      {
        provider: "identity",
        info: {
          date_of_birth: "1986-01-02",
          email: "test@example.com",
          family_name: "User",
          given_name: "Test",
          name: "Test User",
          trn: "123456"
        },
        credentials: {
          token: "token",
          expires_at: (Time.zone.now + 1.hour).to_i
        }
      }
    )
  end
  alias_method :and_identity_auth_is_mocked, :given_identity_auth_is_mocked

  def when_i_go_to_the_sign_in_page
    visit sign_in_path
  end

  def and_click_the_sign_in_button
    click_button "Sign in with Identity"
  end
end
