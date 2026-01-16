# Built to abstract the logic around the current session and user authentication method.
class CurrentSession
  attr_reader :session

  OMNIAUTH_PROVIDER_SESSION_KEY = :omniauth_provider

  class << self
    def create_session(session, omniauth_auth_data)
      CurrentSession.new(session).tap do |current_session|
        current_session.store_oauth_session_data(omniauth_auth_data)
      end
    end
  end

  def initialize(session)
    @session = session
  end

  # Takes in the data from request.env["omniauth.auth"] during an oauth callback
  # and sets up the session data accordingly
  def store_oauth_session_data(omniauth_auth_data)
    provider = omniauth_auth_data.provider

    user = User.from_auth(omniauth_auth_data)

    session[OMNIAUTH_PROVIDER_SESSION_KEY] = provider
    session[user_id_session_key]           = user.id
    session[user_token_session_key]        = omniauth_auth_data.credentials.token
    session[user_token_expiry_session_key] = omniauth_auth_data.credentials.expires_in.seconds.from_now.to_i
    session[user_id_token_session_key]     = omniauth_auth_data.credentials.id_token
  end

  def current_user
    user_id = session[user_id_session_key]
    return nil if user_id.blank?

    @current_user ||= User.find_by(id: user_id)
  end

  def logged_in_via_one_login?
    omniauth_provider == :onelogin
  end

  def session_expired?
    expiry_token.nil? || session_expiry_time.past?
  end

  def session_expiry_time
    Time.zone.at(expiry_token) if expiry_token.present?
  end

  def user_token
    session[user_token_session_key]
  end

  def logout_path
    if logged_in_via_one_login?
      id_token = session[user_id_token_session_key]
      "/qualifications/users/auth/onelogin/logout?id_token_hint=#{id_token}"
    else
      "/qualifications/users/auth/identity/logout"
    end
  end

  def omniauth_provider
    session[OMNIAUTH_PROVIDER_SESSION_KEY]&.to_sym
  end

  def user_id_session_key
    "#{omniauth_provider}_user_id".to_sym
  end

  def user_token_session_key
    "#{omniauth_provider}_user_token".to_sym
  end

  def user_token_expiry_session_key
    "#{omniauth_provider}_user_token_expiry".to_sym
  end

  def user_id_token_session_key
    "#{omniauth_provider}_id_token".to_sym
  end

  private

  def expiry_token
    session[user_token_expiry_session_key]
  end
end

