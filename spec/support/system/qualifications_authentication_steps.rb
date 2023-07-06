module QualificationAuthenticationSteps
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
          email: "test@example.com",
          first_name: "User",
          last_name: "Test",
          name: "Test User"
        },
        credentials: {
          token: "token",
          expires_in: 1.hour.to_i
        },
        extra: {
          raw_info: {
            birthdate: "1986-01-02",
            trn: "123456"
          }
        }
      }
    )
  end
  alias_method :and_identity_auth_is_mocked, :given_identity_auth_is_mocked

  def when_i_go_to_the_sign_in_page
    visit qualifications_root_path
  end

  def and_click_the_sign_in_button
    click_button "Start now"
  end
end
