require "rails_helper"

# form-action is built once at boot from ENV, so reload the initializer with the
# provider vars stubbed to exercise it, then reload again to restore.
RSpec.describe "config/initializers/content_security_policy" do
  def initializer_path
    Rails.root.join("config/initializers/content_security_policy.rb")
  end

  def form_action_with_env(overrides)
    with_env(overrides) do
      load initializer_path
      Rails.application.config.content_security_policy.directives.fetch("form-action").dup
    end
  ensure
    load initializer_path # restore the policy built from the real (test) ENV
  end

  def with_env(overrides)
    originals = overrides.to_h { |key, _value| [key, ENV[key]] }
    overrides.each { |key, value| ENV[key] = value }
    yield
  ensure
    originals.each { |key, value| value.nil? ? ENV.delete(key) : ENV[key] = value }
  end

  it "always allows the government auth domain families" do
    sources = form_action_with_env({})

    expect(sources).to include(
      "'self'",
      "https://*.education.gov.uk",
      "https://*.account.gov.uk",
    )
  end

  # The families are decoupled from the env vars, so a provider pointed outside
  # them must still be allowed via its derived exact origin.
  it "also allows each configured provider origin, including ones outside the families" do
    sources = form_action_with_env(
      "IDENTITY_API_DOMAIN" => "https://identity.example.com/some/path",
      "ONELOGIN_API_DOMAIN" => "https://oidc.account.gov.uk",
      "DFE_SIGN_IN_ISSUER" => "https://pp-oidc.signin.education.gov.uk",
    )

    expect(sources).to include(
      "https://identity.example.com",
      "https://oidc.account.gov.uk",
      "https://pp-oidc.signin.education.gov.uk",
    )
  end

  it "ignores non-HTTPS or placeholder provider values" do
    sources = form_action_with_env(
      "IDENTITY_API_DOMAIN" => "override-locally",
      "ONELOGIN_API_DOMAIN" => "",
      "DFE_SIGN_IN_ISSUER" => "http://insecure.example.com",
    )

    expect(sources).to eq(
      ["'self'", "https://*.education.gov.uk", "https://*.account.gov.uk"],
    )
  end

  # Malformed values must be dropped, not turned into a junk "https://" source.
  it "ignores unparseable or host-less provider values" do
    sources = form_action_with_env(
      "IDENTITY_API_DOMAIN" => "https://[", # unparseable -> URI::InvalidURIError
      "ONELOGIN_API_DOMAIN" => "https:", # HTTPS scheme, no host
      "DFE_SIGN_IN_ISSUER" => "https://", # HTTPS scheme, no host
    )

    expect(sources).to eq(
      ["'self'", "https://*.education.gov.uk", "https://*.account.gov.uk"],
    )
  end
end
