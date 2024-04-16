require "dfe_sign_in"
require "omniauth/strategies/dfe_openid_connect"

OmniAuth.config.add_camelization('dfe_openid_connect', 'DfEOpenIDConnect')
OmniAuth.config.logger = Rails.logger
OmniAuth.config.on_failure =
  proc { |env| AuthFailuresController.action(:failure).call(env) }

if DfESignIn.bypass?
  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :developer,
             fields: %i[uid email first_name last_name],
             uid_field: :uid,
             path_prefix: "/check-records/auth"
  end
else
  dfe_sign_in_issuer_uri = URI(ENV.fetch("DFE_SIGN_IN_ISSUER", "example"))

  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :dfe_openid_connect,
             name: :dfe,
             callback_path: "/check-records/auth/dfe/callback",
             logout_path: "/sign-out",
             post_logout_redirect_uri: "#{ENV['CHECK_RECORDS_DOMAIN']}/check-records/sign-out",
             client_options: {
               host: dfe_sign_in_issuer_uri&.host,
               identifier: ENV["DFE_SIGN_IN_CLIENT_ID"],
               port: dfe_sign_in_issuer_uri&.port,
               redirect_uri: ENV["DFE_SIGN_IN_REDIRECT_URL"],
               scheme: dfe_sign_in_issuer_uri&.scheme,
               secret: ENV.fetch("DFE_SIGN_IN_SECRET", "example")
             },
             discovery: true,
             issuer: "#{dfe_sign_in_issuer_uri}:#{dfe_sign_in_issuer_uri.port}",
             path_prefix: "/check-records/auth",
             response_type: :code,
             scope: %i[email organisation profile]
  end
end

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :openid_connect,
           name: :identity,
           allow_authorize_params: %i[session_id trn_token],
           callback_path: "/qualifications/users/auth/identity/callback",
           client_options: {
             host: URI(ENV["IDENTITY_API_DOMAIN"]).host,
             identifier: ENV["IDENTITY_CLIENT_ID"],
             port: 443,
             redirect_uri:
               "#{ENV["HOSTING_DOMAIN"]}/qualifications/users/auth/identity/callback",
             scheme: "https",
             secret: ENV["IDENTITY_CLIENT_SECRET"]
           },
           discovery: true,
           issuer: ENV["IDENTITY_API_DOMAIN"],
           path_prefix: "/qualifications/users/auth",
           pkce: true,
           post_logout_redirect_uri:
             "#{ENV["HOSTING_DOMAIN"]}/qualifications/sign-out",
           response_type: :code,
           scope: %w[email openid profile dqt:read]
end

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :dfe_openid_connect,
           name: :onelogin,
           allow_authorize_params: %i[session_id trn_token],
           callback_path: "/qualifications/users/auth/onelogin/callback",
           send_scope_to_token_endpoint: false,
           client_options: {
             authorization_endpoint: "/oauth2/authorize",
             end_session_endpoint: "/oauth2/logout",
             token_endpoint: "/oauth2/token",
             userinfo_endpoint: "/oauth2/userinfo",
             host: URI(ENV.fetch("ONELOGIN_API_DOMAIN", "not_set")).host,
             identifier: ENV["ONELOGIN_CLIENT_ID"],
             jwks_uri: ENV["ONELOGIN_JWKS_URI"],
             port: 443,
             redirect_uri:
               "#{ENV["HOSTING_DOMAIN"]}/qualifications/users/auth/onelogin/callback",
             scheme: "https",
             secret: ENV["ONELOGIN_CLIENT_SECRET"]
           },
           discovery: true,
           issuer: ENV["ONELOGIN_ISSUER"],
           path_prefix: "/qualifications/users/auth",
           pkce: true,
           post_logout_redirect_uri:
             "#{ENV["HOSTING_DOMAIN"]}/qualifications/sign-out",
           response_type: :code,
           scope: %w[email openid profile teaching_record]
end
