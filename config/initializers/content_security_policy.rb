# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

require "uri"

# form-action is enforced on every hop of the sign-in redirect chain, not just
# the form's target, so 'self' alone blocks the OAuth round-trip. Allow the
# configured providers (so it follows the env vars) plus the government domain
# families they federate on to — notably One Login, which is fronted by a DfE
# broker that hands the browser to account.gov.uk, a host in no env var.
configured_provider_origins =
  [
    ENV["IDENTITY_API_DOMAIN"],
    ENV["ONELOGIN_API_DOMAIN"],
    ENV["DFE_SIGN_IN_ISSUER"],
  ].filter_map do |value|
    uri = URI.parse(value.to_s)
    uri.origin if uri.is_a?(URI::HTTPS) && uri.host.present?
  rescue URI::InvalidURIError
    nil
  end

government_auth_families = %w[https://*.education.gov.uk https://*.account.gov.uk]

auth_provider_form_actions = (government_auth_families + configured_provider_origins).uniq

Rails.application.configure do
  config.content_security_policy do |policy|
    # First-party only. The ITHC flagged the previous :https scheme (any HTTPS
    # host, which also neutered the script-src nonce); everything is bundled
    # locally, so :self suffices.
    policy.default_src     :self
    policy.base_uri        :self
    policy.connect_src     :self
    policy.font_src        :self
    policy.form_action     :self, *auth_provider_form_actions
    policy.frame_ancestors :none
    policy.frame_src       :none
    policy.img_src         :self
    policy.object_src      :none
    policy.script_src      :self
    policy.style_src       :self
    # Specify URI for violation reports
    # policy.report_uri "/csp-violation-report-endpoint"
  end

  # Per-response random nonce — it must be unguessable now the policy enforces it.
  config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w[script-src]

  # Report violations without enforcing the policy.
  # config.content_security_policy_report_only = true
end
