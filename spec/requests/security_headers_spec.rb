require "rails_helper"

RSpec.describe "Security headers", type: :request do
  # The Content-Security-Policy is applied by Rails middleware to every
  # response, so any unauthenticated route exercises it.
  describe "Content-Security-Policy" do
    let(:policy) do
      get "/health"
      response.headers["Content-Security-Policy"]
    end

    it "restricts every directive to first-party sources" do
      expect(policy).to include("default-src 'self'")
      expect(policy).to include("base-uri 'self'")
      expect(policy).to include("connect-src 'self'")
      expect(policy).to include("font-src 'self'")
      expect(policy).to include("frame-ancestors 'none'")
      expect(policy).to include("frame-src 'none'")
      expect(policy).to include("img-src 'self'")
      expect(policy).to include("object-src 'none'")
      expect(policy).to include("style-src 'self'")
    end

    # form-action must allow the providers the sign-in forms redirect out to
    # (see the initializer); browsers enforce it on every hop.
    it "allows first-party and the government auth domain families in form-action" do
      expect(policy).to include(
        "form-action 'self' https://*.education.gov.uk https://*.account.gov.uk",
      )
    end

    it "permits nonce-based inline scripts but no external scripts" do
      expect(policy).to match(/script-src 'self' 'nonce-[^']+'/)
    end

    # Only the bare :https scheme is the finding; an explicit https://host
    # origin (e.g. the auth providers) is fine.
    it "does not allow the bare https: scheme as a source" do
      expect(policy).not_to match(%r{https:(?!//)})
    end

    # Nothing in the compiled assets uses data: URIs, so the permissive
    # scheme is dropped entirely.
    it "does not allow the data: scheme as a source" do
      expect(policy).not_to include("data:")
    end
  end

  # A header-only check won't catch a nonce that fails to reach the markup, so
  # render a real page and confirm it matches across meta tag, script and header.
  describe "nonce injection in rendered pages" do
    # App pages sit behind HTTP Basic auth in non-open environments.
    let(:credentials) do
      ActionController::HttpAuthentication::Basic.encode_credentials(
        ENV.fetch("SUPPORT_USERNAME", "test"),
        ENV.fetch("SUPPORT_PASSWORD", "test"),
      )
    end

    shared_examples "a page with an end-to-end nonce" do |host, path|
      before do
        host! host
        get path, headers: { "HTTP_AUTHORIZATION" => credentials }
      end

      let(:header_nonce) do
        response.headers["Content-Security-Policy"][/script-src 'self' 'nonce-([^']+)'/, 1]
      end
      let(:meta_nonce) { response.body[/<meta name="csp-nonce" content="([^"]+)"/, 1] }
      let(:script_nonce) { response.body[/<script nonce="([^"]+)"/, 1] }

      it "renders successfully" do
        expect(response).to have_http_status(:ok)
      end

      it "injects the nonce into the csp_meta_tag and the inline script tag" do
        expect(meta_nonce).to be_present
        expect(script_nonce).to be_present
      end

      it "uses the same nonce in the meta tag, inline script and CSP header" do
        expect(meta_nonce).to eq(header_nonce)
        expect(script_nonce).to eq(header_nonce)
      end
    end

    # The cookies page skips authentication and renders the base layout.
    context "qualifications (base layout)" do
      it_behaves_like "a page with an end-to-end nonce",
                      "qualifications.localhost",
                      "/qualifications/cookies"
    end

    # The terms and conditions page skips DfE Sign-in and renders the
    # check_records layout.
    context "check records (check_records layout)" do
      it_behaves_like "a page with an end-to-end nonce",
                      "check_records.localhost",
                      "/check-records/terms-and-conditions"
    end
  end
end
