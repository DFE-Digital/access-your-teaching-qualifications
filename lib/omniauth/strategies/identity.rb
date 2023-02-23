module Omniauth
  module Strategies
    class Identity < OmniAuth::Strategies::OAuth2
      option :name, :identity

      option :client_options,
             {
               site: ENV.fetch("IDENTITY_API_DOMAIN"),
               authorize_url: "/connect/authorize",
               token_url: "/connect/token"
             }
      option :pkce, true
      option :scope, "dqt:read"

      uid { raw_info["sub"] }

      info do
        {
          email: raw_info["email"].downcase,
          email_verified: parsed_email_verified,
          name: raw_info["name"],
          given_name: raw_info["given_name"],
          family_name: raw_info["family_name"],
          trn: raw_info["trn"],
          date_of_birth: raw_info["birthdate"]
        }
      end

      extra { { "raw_info" => raw_info } }

      def raw_info
        @raw_info ||= access_token.get("connect/userinfo").parsed
      end

      def parsed_email_verified
        raw_info["email_verified"] == "True"
      end

      def build_access_token
        verifier = request.params["code"]
        redirect_uri = full_host + callback_path
        client.auth_code.get_token(
          verifier,
          { redirect_uri: }.merge(token_params.to_hash(symbolize_keys: true)),
          deep_symbolize(options.auth_token_params)
        )
      end
    end
  end
end
