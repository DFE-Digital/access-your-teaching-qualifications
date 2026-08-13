# AYTQ Authentication

Access Your Teaching Qualifications (AYTQ) authenticates teachers so they can view their own teaching record, download certificates, and submit change requests. The service supports two OpenID Connect authentication providers:

- **GOV.UK One Login** — the newer, government-wide identity system that is replacing service-specific auth providers across GOV.UK services.
- **DfE Identity** (also known as the TRS Auth Server) — the older, DfE-specific identity system built for the Teaching Record System.

GOV.UK One Login is the only option offered to teachers. The DfE Identity middleware is still registered, but nothing in the UI links to it, so no new DfE Identity sessions can be started. The application still tracks which provider was used for a session to drive UI differences and sign-out behaviour, because sessions created before the option was withdrawn remain valid until their token expires.

## GOV.UK One Login

See [one_login.md](one_login.md) for full details.

## DfE Identity

**DfE Identity is being decommissioned and replaced by GOV.UK One Login.** It is no longer reachable from the sign-in or start pages; the remaining code exists only to serve sessions that already exist. All development should target the One Login flow.

See [dfe_identity.md](dfe_identity.md) for full details.

## How they coexist

Both providers are registered as OmniAuth middleware simultaneously in `config/initializers/omniauth.rb`. They share a callback controller (`Qualifications::Users::OmniauthCallbacksController`) and a `User` model — the same `User.from_auth` method handles data from either provider. The session tracks which provider was used via the `omniauth_provider` key, which determines navigation links, the account page shown, and the sign-out flow.

A `one_login` feature flag is defined in `config/feature_flags.yml` but is not checked anywhere in code. Which provider a teacher can use is decided by the sign-in views, not by that flag.
