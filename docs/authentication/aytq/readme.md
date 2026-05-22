# AYTQ Authentication

Access Your Teaching Qualifications (AYTQ) authenticates teachers so they can view their own teaching record, download certificates, and submit change requests. The service supports two OpenID Connect authentication providers:

- **GOV.UK One Login** — the newer, government-wide identity system that is replacing service-specific auth providers across GOV.UK services.
- **DfE Identity** (also known as the TRS Auth Server) — the older, DfE-specific identity system built for the Teaching Record System.

Both providers are currently active simultaneously. The sign-in page presents both options to the user, and the application tracks which provider was used for the session to drive UI differences and sign-out behaviour.

## GOV.UK One Login

See [one_login.md](one_login.md) for full details.

## DfE Identity

**DfE Identity is being deprecated and replaced by GOV.UK One Login.** Both providers coexist during the transition period, but new development should target the One Login flow.

See [dfe_identity.md](dfe_identity.md) for full details.

## How they coexist

Both providers are registered as OmniAuth middleware simultaneously in `config/initializers/omniauth.rb`. They share a callback controller (`Qualifications::Users::OmniauthCallbacksController`) and a `User` model — the same `User.from_auth` method handles data from either provider. The session tracks which provider was used via the `omniauth_provider` key, which determines navigation links, the account page shown, and the sign-out flow.

A `one_login` feature flag is defined in `config/feature_flags.yml` but is not currently checked in code — both options are always available, with One Login gated only by the absence of a DfE Identity registration bypass token in the session.
