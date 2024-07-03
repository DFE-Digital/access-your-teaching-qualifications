module QualificationAuthenticationSteps
  def and_i_am_signed_in
    @user = create(:user)
    sign_in(@user)
  end

  def given_i_am_signed_in_via_identity
    given_identity_auth_is_mocked
    when_i_go_to_the_sign_in_page
    and_click_the_sign_in_button
  end
  alias_method :and_i_am_signed_in_via_identity, :given_i_am_signed_in_via_identity


  def and_i_am_signed_in_via_onelogin
    given_onelogin_auth_is_mocked
    when_i_go_to_the_sign_in_page
    and_click_the_onelogin_sign_in_button
  end

  def given_auth_is_mocked_for(provider:)
    OmniAuth.config.mock_auth[provider] = OmniAuth::AuthHash.new(
      {
        provider:,
        info: {
          email: "test@example.com",
          first_name: "User",
          last_name: "Test",
          name: "Test User"
        },
        credentials: {
          token: "token",
          id_token: "id_token",
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

  def given_identity_auth_is_mocked
    given_auth_is_mocked_for(provider: :identity)
  end
  alias_method :and_identity_auth_is_mocked, :given_identity_auth_is_mocked

  def given_onelogin_auth_is_mocked
    given_auth_is_mocked_for(provider: :onelogin)
  end
  alias_method :and_onelogin_auth_is_mocked, :given_onelogin_auth_is_mocked


  def when_i_go_to_the_sign_in_page
    visit qualifications_root_path
  end

  def and_click_the_sign_in_button
    click_button "Sign in with DfE Identity"
  end

  def and_click_the_onelogin_sign_in_button
    click_button "Sign in with GOV.UK One Login"
  end
end
