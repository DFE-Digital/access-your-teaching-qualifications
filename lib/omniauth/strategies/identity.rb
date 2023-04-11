module OmniAuth
  module Strategies
    class Identity < OmniAuth::Strategies::OAuth2
      option :name, :identity

      option :client_options,
             {
               authorize_url: "/connect/authorize",
               site: ENV.fetch("IDENTITY_API_DOMAIN"),
               token_url: "/connect/token"
             }
      option :pkce, true
      option :scope, "dqt:read"

      uid { raw_info["sub"] }

      info do
        {
          date_of_birth: raw_info["birthdate"],
          email: raw_info["email"].downcase,
          email_verified: parsed_email_verified,
          family_name: raw_info["family_name"],
          given_name: raw_info["given_name"],
          name: raw_info["name"],
          trn: raw_info["trn"]
        }
      end

      extra { { "raw_info" => raw_info } }

      def raw_info
        @raw_info ||= access_token.get("connect/userinfo").parsed
      end

      def parsed_email_verified
        raw_info["email_verified"] == "True"
      end

      def callback_url
        full_host + callback_path
      end
    end
  end
end
