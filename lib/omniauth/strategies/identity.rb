module OmniAuth
  module Strategies
    class Identity < OmniAuth::Strategies::OAuth2
      option :name, :identity

      option :client_options,
             {
               authorize_url: "connect/authorize",
               end_session_uri: "connect/signout",
               site: ENV.fetch("IDENTITY_API_DOMAIN"),
               token_url: "connect/token"
             }
      option :authorize_options, %i[scope state session_id trn_token]
      option :trn_token,
             lambda { |env|
               request = Rack::Request.new(env)
               request.params["trn_token"]
             }
      option :session_id,
             lambda { |env|
               request = Rack::Request.new(env)
               request.session.id
             }

      option :pkce, true
      option :scope, "dqt:read"
      option :post_logout_redirect_uri, "#{ENV.fetch("HOSTING_DOMAIN")}/qualifications/sign-out"
      option :logout_path, "/logout"

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

      def other_phase
        if logout_path_pattern.match?(current_path) && end_session_uri
          return redirect(end_session_uri)
        end
        call_app!
      end

      private

      def client_options
        options.client_options
      end

      def encoded_post_logout_redirect_uri
        return unless options.post_logout_redirect_uri

        URI.encode_www_form(post_logout_redirect_uri: options.post_logout_redirect_uri)
      end

      def end_session_uri
        end_session_uri = URI(client_options.site + client_options.end_session_uri)
        end_session_uri.query = encoded_post_logout_redirect_uri
        end_session_uri.to_s
      end

      def logout_path_pattern
        @logout_path_pattern ||= /\A#{Regexp.quote(request_path)}#{options.logout_path}/
      end
    end
  end
end
