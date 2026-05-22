# GOV.UK One Login Authentication

GOV.UK One Login is the primary authentication provider for AYTQ. It uses OpenID Connect (OIDC) with PKCE to authenticate teachers, and provides identity-verified personal details alongside a token that the Qualifications API uses to resolve the teacher's record.

The OmniAuth provider is named `:onelogin` and uses a custom strategy (`DfEOpenIDConnect`) that extends the standard `omniauth_openid_connect` gem to support the `id_token_hint` parameter required for sign-out.

## Configuration

The provider is configured in `config/initializers/omniauth.rb` with the following environment variables:

| Variable                 | Purpose                                                                    |
| ------------------------ | -------------------------------------------------------------------------- |
| `ONELOGIN_API_DOMAIN`    | Base URL of the One Login service (used for host and end-session endpoint) |
| `ONELOGIN_CLIENT_ID`     | OAuth2 client ID registered with One Login                                 |
| `ONELOGIN_CLIENT_SECRET` | OAuth2 client secret                                                       |
| `ONELOGIN_ISSUER`        | Issuer URL for token validation                                            |
| `ONELOGIN_JWKS_URI`      | JSON Web Key Set endpoint for verifying signed tokens                      |
| `HOSTING_DOMAIN`         | Application domain, used to construct callback and redirect URIs           |

Key configuration details:

- PKCE is enabled
- Discovery is enabled (configuration fetched from the provider's `.well-known/openid-configuration`)
- Response type is `:code` (authorization code flow)
- Scopes requested: `email openid profile teaching_record`
- `send_scope_to_token_endpoint` is set to `false` — One Login does not accept scope in the token exchange request
- Extra authorize params: `session_id`, `trn_token`

## Sign-in

The sign-in follows a standard OIDC authorization code flow with PKCE. The teacher clicks "Sign in with GOV.UK One Login", authenticates with One Login, and is redirected back to `/qualifications/users/auth/onelogin/callback`. The callback controller (`OmniauthCallbacksController#complete`) calls `CurrentSession.create_session(session, auth)` to set up the session.

## Callback data

The auth hash from One Login provides:

| Field                                              | Source                          | Used for                                              |
| -------------------------------------------------- | ------------------------------- | ----------------------------------------------------- |
| `auth.info.email`                                  | OIDC claims                     | Stored on User                                        |
| `auth.info.first_name`                             | OIDC claims                     | Stored on User                                        |
| `auth.info.last_name`                              | OIDC claims                     | Stored on User                                        |
| `auth.info.name`                                   | OIDC claims                     | Stored on User                                        |
| `auth.extra.raw_info.birthdate`                    | OIDC claims                     | Stored on User as `date_of_birth`                     |
| `auth.extra.raw_info.trn`                          | Teaching record scope           | Stored on User                                        |
| `auth.uid`                                         | OIDC subject identifier         | Stored on User as `auth_uuid`                         |
| `auth.credentials.token`                           | Access token                    | Used as Bearer token for Qualifications API calls     |
| `auth.credentials.expires_in`                      | Token lifetime in seconds       | Used to calculate session expiry                      |
| `auth.credentials.id_token`                        | ID token                        | Stored for use in sign-out (`id_token_hint`)          |
| `auth.extra.raw_info.onelogin_verified_names`      | One Login identity verification | Stored as `one_login_verified_name` (encrypted)       |
| `auth.extra.raw_info.onelogin_verified_birthdates` | One Login identity verification | Stored as `one_login_verified_birth_date` (encrypted) |

The One Login-specific verified fields (`onelogin_verified_names`, `onelogin_verified_birthdates`) contain identity-verified data that has been checked against government records. These are stored encrypted on the User model and can be distinguished from self-declared data.

## Session management

After successful authentication, `CurrentSession` stores the following in the Rails session (database-backed via `activerecord-session_store`):

- `omniauth_provider` — set to `:onelogin`
- `onelogin_user_id` — the local User record ID
- `onelogin_user_token` — the access token (used as Bearer token for API calls)
- `onelogin_user_token_expiry` — token expiry timestamp (computed from `expires_in`)
- `onelogin_id_token` — the ID token (needed for sign-out)

On each request, `QualificationsInterfaceController` redirects to sign-in if no session exists (`authenticate_user!`) and redirects to sign-in again if the token has expired (`handle_expired_token!`).

The stored `onelogin_user_token` is passed to `QualificationsApi::Client.new(token:)` to authenticate API calls. The Qualifications API resolves the teacher's record from this token, so no TRN needs to be passed explicitly.

## UI differences

When `current_session.logged_in_via_one_login?` is true:

- The GOV.UK One Login header component is rendered with a link to the One Login account management page
- The dashboard links to `/qualifications/one-login-user` for account details
- The account page shows the teacher's details, One Login-verified name and DOB, and allows name change and date of birth change requests

## Sign-out

Sign-out goes through a confirmation page at `/qualifications/sign-out/new`. On confirmation, the Rails session is reset, and the user is redirected to One Login's end-session endpoint with the `id_token_hint` parameter (via the custom `DfEOpenIDConnect` strategy). One Login requires `id_token_hint` to know which session to invalidate. After invalidation, One Login redirects back to `{HOSTING_DOMAIN}/qualifications/sign-out`, which redirects to the AYTQ root.

## Error handling

Authentication failures are handled by `AuthFailuresController#failure`. Errors are logged to Sentry in non-development environments, and the user is redirected to `qualifications_root_path`. Session expiry errors (message `"sessionexpired"`) are detected separately.

At the API level, if the One Login token has expired or is invalid, the Qualifications API returns a 401 or 403, which the application handles by redirecting to sign-out (see the [Qualifications API documentation](../../api_integrations/qualifications_api.md) for details).
