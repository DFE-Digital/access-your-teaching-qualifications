class AuthFailuresController < ApplicationController
  class OpenIdConnectProtocolError < StandardError; end

  def failure
    strategy = request.env["omniauth.error.strategy"].name

    case strategy
    when :identity
      handle_failure_then_redirect_to qualifications_root_path
    when :onelogin
      handle_failure_then_redirect_to qualifications_root_path
    when :dfe
      return redirect_to(
        check_records_dsi_sign_out_path(id_token_hint: session[:id_token])
      ) if session_expired?

      handle_failure_then_redirect_to check_records_sign_in_path(oauth_failure: true)
    when :staff
      return redirect_to(
        support_interface_dsi_sign_out_path(id_token_hint: session[:id_token])
      ) if session_expired?

      handle_failure_then_redirect_to support_interface_sign_in_path(oauth_failure: true)
    end
  end

  private

  def handle_failure_then_redirect_to(path)
    oidc_error = OpenIdConnectProtocolError.new(error_message)
    unless Rails.env.development?
      Sentry.capture_exception(oidc_error)
      flash[:warning] = I18n.t("validation_errors.generic_oauth_failure")
      redirect_to(path) and return
    end

    raise oidc_error
  end

  def error_message
    @error_message ||= request.env["omniauth.error"]&.message
  end

  def session_expired?
    error_message == "sessionexpired"
  end
end
