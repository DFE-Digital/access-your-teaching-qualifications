require "check_records/dfe_sign_in"
require "omniauth/strategies/identity"

OmniAuth.config.logger = Rails.logger

# DSI setup
dfe_sign_in_identifier = ENV.fetch("DFE_SIGN_IN_CLIENT_ID", "example")
dfe_sign_in_secret = ENV.fetch("DFE_SIGN_IN_SECRET", "example")
dfe_sign_in_redirect_uri = ENV.fetch("DFE_SIGN_IN_REDIRECT_URL", "example")
dfe_sign_in_issuer_uri = ENV["DFE_SIGN_IN_ISSUER"].present? ? URI(ENV["DFE_SIGN_IN_ISSUER"]) : nil
options = {
  name: :dfe,
  discovery: true,
  response_type: :code,
  scope: %i[email profile],
  path_prefix: "/check-records/auth",
  callback_path: "/check-records/auth/dfe/callback",
  client_options: {
    port: dfe_sign_in_issuer_uri&.port,
    scheme: dfe_sign_in_issuer_uri&.scheme,
    host: dfe_sign_in_issuer_uri&.host,
    identifier: dfe_sign_in_identifier,
    secret: dfe_sign_in_secret,
    redirect_uri: dfe_sign_in_redirect_uri&.to_s
  }
}
if CheckRecords::DfESignIn.bypass?
  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :developer,
             fields: %i[uid email first_name last_name],
             uid_field: :uid,
             path_prefix: "/check-records/auth"
  end
else
  Rails.application.config.middleware.use OmniAuth::Strategies::OpenIDConnect, options
end

# Identity setup
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :identity,
           ENV.fetch("IDENTITY_CLIENT_ID"),
           ENV.fetch("IDENTITY_CLIENT_SECRET"),
           { path_prefix: "/users/auth" }
end
