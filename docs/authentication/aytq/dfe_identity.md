# DfE Identity Authentication

> **Deprecation notice:** DfE Identity is being replaced by GOV.UK One Login. Both providers currently coexist, but DfE Identity will be removed once the migration to One Login is complete. New development should target the One Login flow.

DfE Identity (also known as the TRS Auth Server) is a sign-in service maintained by the Teaching Record System (TRS) team. It was built specifically for DfE teaching services and provides OpenID Connect authentication alongside access to the teacher's TRN and personal details.

The OmniAuth provider is named `:identity` and uses the standard `omniauth_openid_connect` gem strategy.

## Configuration

The provider is configured in `config/initializers/omniauth.rb` with the following environment variables:

| Variable                 | Purpose                                                                  |
| ------------------------ | ------------------------------------------------------------------------ |
| `IDENTITY_API_DOMAIN`    | Base URL of the DfE Identity auth server (used for issuer and discovery) |
| `IDENTITY_CLIENT_ID`     | OAuth2 client ID (default: `access-your-teaching-certificates`)          |
| `IDENTITY_CLIENT_SECRET` | OAuth2 client secret                                                     |
| `HOSTING_DOMAIN`         | Application domain, used to construct callback and redirect URIs         |

Key configuration details:

- PKCE is enabled
- Discovery is enabled (configuration fetched from the provider's `.well-known/openid-configuration`)
- Response type is `:code` (authorization code flow)
- Scopes requested: `email openid profile dqt:read`
- Extra authorize params: `session_id`, `trn_token`, `registration_token`

The `dqt:read` scope is specific to DfE Identity and grants the issued token read access to the teacher's record via the Qualifications API.

## Sign-in

The sign-in follows a standard OIDC authorization code flow. The teacher clicks the DfE Identity option, authenticates with DfE Identity, and is redirected back to `/qualifications/users/auth/identity/callback`. The callback controller (`OmniauthCallbacksController#complete`) calls `CurrentSession.create_session(session, auth)` to set up the session.

### Registration bypass token

DfE Identity does not currently support new user registration on its own. It supports a `registration_token` parameter to enable this when necessary.

If a teacher arrives at AYTQ with a registration bypass token (stored in the session as `identity_new_registration_bypass_token`), this token is passed through to DfE Identity in the authorize request. When present, the One Login sign-in option is hidden from the UI (via `one_login_available?` returning false), ensuring the teacher completes the DfE Identity registration flow.

## Callback data

The auth hash from DfE Identity provides:

| Field                           | Source                    | Used for                                          |
| ------------------------------- | ------------------------- | ------------------------------------------------- |
| `auth.info.email`               | OIDC claims               | Stored on User                                    |
| `auth.info.first_name`          | OIDC claims               | Stored on User                                    |
| `auth.info.last_name`           | OIDC claims               | Stored on User                                    |
| `auth.info.name`                | OIDC claims               | Stored on User                                    |
| `auth.extra.raw_info.birthdate` | OIDC claims               | Stored on User as `date_of_birth`                 |
| `auth.extra.raw_info.trn`       | DfE Identity              | Stored on User                                    |
| `auth.uid`                      | OIDC subject identifier   | Stored on User as `auth_uuid`                     |
| `auth.credentials.token`        | Access token              | Used as Bearer token for Qualifications API calls |
| `auth.credentials.expires_in`   | Token lifetime in seconds | Used to calculate session expiry                  |
| `auth.credentials.id_token`     | ID token                  | Stored for use in sign-out                        |

Unlike One Login, DfE Identity does not provide identity-verified fields (`onelogin_verified_names`, `onelogin_verified_birthdates`), so the `one_login_verified_name` and `one_login_verified_birth_date` fields on the User model will be nil for Identity-authenticated users.

## Session management

After successful authentication, `CurrentSession` stores the following in the Rails session:

- `omniauth_provider` — set to `:identity`
- `identity_user_id` — the local User record ID
- `identity_user_token` — the access token (used as Bearer token for API calls)
- `identity_user_token_expiry` — token expiry timestamp
- `identity_id_token` — the ID token

Session expiry and token handling work identically to One Login — see the [One Login documentation](one_login.md#session-management) for the shared mechanics. The only difference is the session key prefix (`identity_` vs `onelogin_`).

## UI differences

When the session provider is `:identity`:

- A standard GOV.UK header is shown with "Account" and "Sign out" links in the service navigation, rather than the One Login header component
- The dashboard links to `/qualifications/identity_user` for account details
- The account page links to the DfE Identity account management page at `{IDENTITY_API_DOMAIN}/account?client_id=...`, where the teacher can manage their details directly
- Name change and date of birth change request forms are not available — these features are only offered to One Login users

## Sign-out

Sign-out works the same way as One Login — confirmation page, session reset, redirect to the provider's end-session endpoint. For DfE Identity, the logout path is `/qualifications/users/auth/identity/logout`. After DfE Identity invalidates the session, the user is redirected back to the AYTQ root.

## Error handling

Authentication failures follow the same pattern as One Login — handled by `AuthFailuresController#failure`, logged to Sentry, and redirected to `qualifications_root_path`. See the [One Login documentation](one_login.md#error-handling) for details.

## Local development

DfE Identity auth works in development with the environment variables set in `.env.development`. The `IDENTITY_API_DOMAIN` points to the DfE Identity development environment. To test the full auth flow locally, you'll need valid credentials for that environment.
