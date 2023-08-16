class AuthFailuresController < ApplicationController
  class OpenIdConnectProtocolError < StandardError; end

  def failure
    strategy = request.env["omniauth.error.strategy"].name

    case strategy
    when :identity
      handle_failure_then_redirect_to qualifications_root_path
    when :dfe
      handle_failure_then_redirect_to check_records_sign_in_path
    end
  end

  private

  def handle_failure_then_redirect_to(path)
    error_message = request.env["omniauth.error"]&.message
    oidc_error = OpenIdConnectProtocolError.new(error_message)
    unless Rails.env.development?
      Sentry.capture_exception(oidc_error)
      flash[:warning] = I18n.t("validation_errors.generic_oauth_failure")
      redirect_to(path) and return
    end

    raise oidc_error
  end
end
