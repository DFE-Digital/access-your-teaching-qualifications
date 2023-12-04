module Qualifications
  class StartsController < QualificationsInterfaceController
    skip_before_action :authenticate_user!
    skip_before_action :handle_expired_token!
    around_action :skip_omniauth_request_validation_phase, only: :show

    def show
      @identity_service_response = Faraday.post(identity_service_auth_url)
      redirect_to_identity_service and return if redirect_present?
    rescue Faraday::Error
      render :show
    end

  private

    attr_reader :identity_service_response

    # Check that the response headers contain a redirect to the identity service
    def redirect_present?
      identity_service_response.status == 302 &&
        identity_service_response.headers["location"]&.starts_with?(identity_api_domain)
    end

    def redirect_to_identity_service
      redirect_to(identity_service_response.headers["location"], allow_other_host: true)
    end

    def identity_service_auth_url
      %(#{ENV["HOSTING_DOMAIN"]}/qualifications/users/auth/identity?trn_token=#{params[:trn_token]})
    end

    # OmniAuth will default to validating the request using CSRF protection
    # which is necessary when the request is sent from a browser.
    # In this case, the request is sent from an action with limited parameters
    # so CSRF protection is not necessary.
    def skip_omniauth_request_validation_phase
      request_validation_phase = OmniAuth.config.request_validation_phase
      OmniAuth.config.request_validation_phase = nil
      yield
    ensure
      OmniAuth.config.request_validation_phase = request_validation_phase
    end

    def identity_api_domain
      ENV["IDENTITY_API_DOMAIN"]
    end
  end
end
