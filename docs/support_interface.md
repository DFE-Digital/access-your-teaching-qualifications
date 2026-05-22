# Support Interface

The Support Interface is an internal admin area used by DfE staff to manage Check a Teacher's Record (CTR). It lives at `/support` and provides tools for managing feature flags, viewing user feedback, and administering DSI role codes.

Authentication is shared with CTR — both use DfE Sign In (DSI). Internal users (DfE staff with an internal role) who sign in through CTR are automatically redirected to the Support Interface. See the [CTR authentication documentation](authentication/ctr/readme.md) for details on the DSI sign-in flow.

## Accessing the support interface

### Locally

In development, the Support Interface is available at `http://localhost:3000/support`.

When `BYPASS_DSI` is true (the default in development), basic auth protects the interface. The credentials are set to `test` / `test` in `.env.development` via the `SUPPORT_USERNAME` and `SUPPORT_PASSWORD` environment variables.

When the `support_service_open` feature flag is active, basic auth is removed. This flag should always be active on production and inactive on non-production environments to prevent accidental public access.

### In deployed environments

Internal users access the Support Interface by signing in through CTR. After authenticating with DSI, users with an internal role are redirected to `/support` automatically.

To gain access, you need to be added as an internal user to the Teaching Qualifications organisation in DSI Manage, and the corresponding internal role code must be present and enabled in the application's `roles` table.

## Features

### Feature flags

**URL:** `/support/features`

We use the `govuk_feature_flags` gem, which provides a web UI for toggling feature flags at runtime. The engine is mounted at `/support/features` and is available to all internal users.

See the [feature flags documentation](feature_flags.md) for a full reference of all flags, what they control, and where they are checked in code.

### Feedback

**URL:** `/support/feedback`

Displays a paginated list of all feedback submissions, ordered by most recent first. Feedback can come from either CTR or AYTQ (the `Feedback` model has a `service` enum distinguishing between them). Each entry shows the user's email, satisfaction rating, improvement suggestion, contact permission, and submission date.

### Role management

**URL:** `/support/roles` (behind the `manage_roles` feature flag)

Allows internal users to manage the DSI role codes that control access to CTR. Each role has three attributes:

- **Code** — the role code string that must match a role assigned in DSI Manage
- **Enabled** — whether this role code grants access to the service
- **Internal** — whether this role code identifies DfE staff (who get access to the Support Interface) or external users (employers, providers, local authorities)

You can create and edit roles through this interface. In production, the role codes and their internal/external designation must align with the roles configured in DSI Manage. See the [CTR authentication documentation](authentication/ctr/readme.md#roles) for how roles are used during sign-in.

### Console auditing

**URL:** `/support/console`

We use the `console1984` and `audits1984` gems to provide audited Rails console access. The Audits1984 engine is mounted at `/support/console` and lets internal users review console session audit logs. Any direct database access via the Rails console is tracked and attributable.

## Authentication and authorisation

The `SupportInterfaceController` base controller includes the `DsiAuthenticatable` concern (shared with CTR) and adds a `check_user_is_internal` check, which redirects to a 404 page if the signed-in user does not have an internal role. Even authenticated external CTR users cannot access the Support Interface.
