# CTR Authentication (DfE Sign In)

Check a Teacher's Record (CTR) and the Support Interface both use DfE Sign In (DSI) for authentication and authorisation. DSI is an OpenID Connect identity provider managed centrally by DfE, separate from the GOV.UK One Login / DfE Identity providers used by AYTQ.

The flow includes a role-based authorisation step: after a user authenticates with DSI, we call the DSI API to verify they have an enabled role for their organisation. Users without a matching role are redirected to a "not authorised" page. Internal users (DfE staff) who sign in through CTR are automatically redirected to the Support Interface.

## Configuration

### OmniAuth provider

The DSI provider is configured in `config/initializers/omniauth.rb` using the custom `DfEOpenIDConnect` strategy, registered with the name `:dfe`:

| Variable                   | Purpose                                                                                   |
| -------------------------- | ----------------------------------------------------------------------------------------- |
| `DFE_SIGN_IN_ISSUER`       | OIDC issuer URL for DSI (e.g. `https://dev-oidc.signin.education.gov.uk`)                 |
| `DFE_SIGN_IN_CLIENT_ID`    | OAuth2 client ID registered with DSI                                                      |
| `DFE_SIGN_IN_SECRET`       | OAuth2 client secret                                                                      |
| `DFE_SIGN_IN_REDIRECT_URL` | Callback URL for CTR (e.g. `http://check.localhost:3000/check-records/auth/dfe/callback`) |
| `CHECK_RECORDS_DOMAIN`     | Domain used to build the `post_logout_redirect_uri`                                       |

Discovery is enabled, the response type is `:code` (authorization code flow), and the scopes requested are `email organisation profile`. The path prefix is `/check-records/auth`. The custom `DfEOpenIDConnect` strategy extends the standard `omniauth_openid_connect` gem to include `id_token_hint` in logout redirects, which DSI requires for session invalidation.

### DSI API

We also call the DSI API (a separate REST API, not the OIDC provider) to check user roles and organisations:

| Variable                                  | Purpose                                                                  |
| ----------------------------------------- | ------------------------------------------------------------------------ |
| `DFE_SIGN_IN_API_BASE_URL`                | Base URL of the DSI API (e.g. `https://dev-api.signin.education.gov.uk`) |
| `DFE_SIGN_IN_API_SECRET`                  | Secret used to sign JWT tokens for API authentication                    |
| `DFE_SIGN_IN_API_AUDIENCE`                | JWT audience claim (e.g. `signin.education.gov.uk`)                      |
| `DFE_SIGN_IN_API_ROLE_CODES`              | Comma-separated list of role codes to seed into the database             |
| `DFE_SIGN_IN_API_INTERNAL_USER_ROLE_CODE` | Role code for internal (DfE staff) users                                 |

The DSI API client (`DfESignInApi::Client`) authenticates using a self-signed JWT (HS256) with the client ID as issuer and the API audience as the `aud` claim. The client code lives in `app/lib/dfe_sign_in_api/` — `GetOrganisationsForUser` fetches a user's organisations (filtering out closed ones), and `GetUserAccessToService` fetches their roles for a specific organisation and service, returning the first matching enabled role (internal roles checked first). The `DfESignIn` class (`app/lib/dfe_sign_in.rb`) provides a `bypass?` helper that returns true in test environments when `BYPASS_DSI=true`, or on review apps.

### Roles

Roles are stored in the `roles` database table and managed via the Support Interface (`/support/roles`). Each role has a `code`, an `enabled` flag, and an `internal` flag that distinguishes DfE staff from external users (employers, providers, local authorities).

When a user signs in, we query the DSI API for their roles at the authenticated organisation, then check whether any of those role codes match an enabled role in the database. Internal roles are checked first, then external roles.

## Sign-in flow

1. The user visits the CTR sign-in page (`/check-records/sign-in`).
2. `SignInController#new` immediately redirects via POST to `/check-records/auth/dfe`, which OmniAuth intercepts to begin the OIDC authorization code flow.
3. The user is redirected to DSI where they authenticate and select an organisation.
4. On success, DSI redirects back to `/check-records/auth/dfe/callback` with an authorization code.
5. OmniAuth exchanges the code for tokens and populates `request.env["omniauth.auth"]`.
6. The callback controller (`CheckRecords::OmniauthCallbacksController#dfe`) runs the authorisation checks:
   a. Fetches the user's organisations via `DfESignInApi::GetOrganisationsForUser` (filtering out closed organisations).
   b. If the authenticated organisation is in the user's organisation list, calls `DfESignInApi::GetUserAccessToService` to retrieve the user's roles for that organisation and service.
   c. Looks for a matching enabled role in the database (internal roles take priority over external).
   d. If no matching role is found, redirects to `/check-records/not-authorised`.
7. On successful authorisation, the controller calls `DsiUser.create_or_update_from_dsi` which find-or-creates a `DsiUser` record by email, updates their name and UID, and creates a `DsiUserSession` record capturing the role and organisation.
8. The user's `dsi_user_id` and a 2-hour session expiry are stored in the Rails session.
9. If the user has an internal role, they're redirected to the Support Interface (`/support`). Otherwise, they're redirected to the CTR root or the page they originally tried to access.
10. After sign-in, `CheckRecordsController` checks whether the user needs to accept the current terms and conditions (version 1.0, re-acceptance required every 12 months). If acceptance is required, the user is redirected to `/check-records/terms-and-conditions`.

## Callback data

The auth hash from DSI provides:

| Field                                   | Source                  | Used for                                         |
| --------------------------------------- | ----------------------- | ------------------------------------------------ |
| `auth.info.email`                       | OIDC claims             | Stored on DsiUser (encrypted, deterministic)     |
| `auth.info.first_name`                  | OIDC claims             | Stored on DsiUser (encrypted)                    |
| `auth.info.last_name`                   | OIDC claims             | Stored on DsiUser (encrypted)                    |
| `auth.uid`                              | OIDC subject identifier | Stored on DsiUser as `uid`                       |
| `auth.credentials.id_token`             | ID token                | Stored in session for sign-out (`id_token_hint`) |
| `auth.extra.raw_info.organisation.id`   | DSI organisation        | Used for role authorisation check                |
| `auth.extra.raw_info.organisation.name` | DSI organisation        | Stored in session and on DsiUserSession          |

## Session management

After successful authentication, we store the following in the Rails session (database-backed via `activerecord-session_store`):

- `dsi_user_id` — the local DsiUser record ID
- `dsi_user_session_expiry` — 2 hours from sign-in time
- `id_token` — the DSI ID token (needed for sign-out)
- `organisation_name` — the name of the organisation the user signed in under

On each request, the `DsiAuthenticatable` concern (included in `CheckRecordsController`) runs two checks: `authenticate_dsi_user!` redirects to the CTR sign-in page if there's no `dsi_user_id` in the session, and `handle_expired_session!` redirects to sign-out if the session has expired.

## Terms and conditions

`CheckRecordsController` enforces terms and conditions acceptance before allowing access to any CTR page. The current T&C version is `1.0` (defined as `DsiUser::CURRENT_TERMS_AND_CONDITIONS_VERSION`). Acceptance expires after 12 months.

When `current_dsi_user.acceptance_required?` returns true, the user is redirected to `/check-records/terms-and-conditions`. On acceptance, the version and timestamp are saved to the `DsiUser` record and the user proceeds to the service.

## Sign-out

The user clicks "Sign out", which navigates to `/check-records/sign-out`. `SignOutController#new` deletes the `dsi_user_id` from the session and redirects to the CTR guidance page (`CHECK_RECORDS_GUIDANCE_URL`, defaulting to `https://www.gov.uk/guidance/check-a-teachers-record`).

This sign-out flow doesn't redirect through DSI's end-session endpoint — it only clears the local session. The DSI session is invalidated separately when an auth failure with a `sessionexpired` error is detected (see error handling below).

## Error handling

Authentication failures are handled by `AuthFailuresController#failure`, which inspects the OmniAuth strategy name to determine the redirect target.

For the `:dfe` strategy (CTR): if the error message is `"sessionexpired"`, the user is redirected to DSI's sign-out endpoint (`/check-records/auth/dfe/sign-out`) with the `id_token_hint` from the session, allowing DSI to invalidate the expired session before the user re-authenticates. For all other errors, the exception is reported to Sentry (in non-development environments) and the user is redirected to the CTR sign-in page with a generic OAuth failure flash message.

For the `:staff` strategy (Support Interface), the same pattern applies but redirects to the Support sign-in page instead.

## The custom OmniAuth strategy

The `DfEOpenIDConnect` strategy (`lib/omniauth/strategies/dfe_openid_connect.rb`) extends `OmniAuth::Strategies::OpenIDConnect` to fix a specific issue: the standard strategy doesn't include `id_token_hint` when building the post-logout redirect URI. DSI's OIDC provider (built on `node-oidc-provider`) requires this parameter to identify which session to invalidate during sign-out. The custom strategy extracts `id_token_hint` from the query string and includes it in the encoded logout redirect.

## Bypass mode (development and review apps)

By default, DSI authentication is bypassed in development (`BYPASS_DSI=true` in `.env.development`) and on review apps. When bypass is active, the OmniAuth initializer registers a `:developer` provider instead of `:dfe` at the `/check-records/auth` path prefix. `SignInController#new` redirects to the developer provider, which presents a simple form for entering user details, and the callback controller skips the DSI API role check entirely.

## Testing with real DSI locally

To test the actual DSI auth flow locally instead of using bypass mode:

1. Get yourself added to the service via the DSI Manage console on the DSI dev environment (`https://dev-manage.signin.education.gov.uk/`). You'll need to be added to an organisation of the correct type and assigned a valid role — see the Policies section in Manage for which organisation types and roles have access to CTR. For Support Interface access, you'll also need to be added as an internal user to the Teaching Qualifications organisation.
2. Set `DFE_SIGN_IN_API_ROLE_CODES` and `DFE_SIGN_IN_API_INTERNAL_USER_ROLE_CODE` in `.env.development.local` with the role codes assigned in step 1, then run `rake db:seed_role_codes` to copy them into the database.
3. Obtain the secret for the CTR service from the DSI Manage console and set `DFE_SIGN_IN_SECRET` to this value in `.env.development.local`.
4. Set `BYPASS_DSI` to `false` in `.env.development.local`.
5. Navigate to `http://check.localhost:3000/check-records/sign-in` and go through the DSI sign-in process.

## Configuring DSI callback and sign-out in DSI Manage

When setting up the DSI integration in a new environment, you need to configure two URLs in DSI Manage:

- **Redirect URL**: `{CHECK_RECORDS_DOMAIN}/check-records/auth/dfe/callback`
- **Logout redirect URL**: `{CHECK_RECORDS_DOMAIN}/check-records/sign-out`
