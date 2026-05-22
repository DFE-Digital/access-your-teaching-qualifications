# Feature Flags

We use the `govuk_feature_flags` gem for runtime feature toggling. Flags are defined in `config/feature_flags.yml` and seeded into the `feature_flags_features` database table by `bin/setup`. You can toggle them on or off through the Support Interface web UI at `/support/features` without a deployment.

In code, check a flag with `FeatureFlags::FeatureFlag.active?(:flag_name)`.

## Adding a new feature flag

1. Add the flag definition to `config/feature_flags.yml` with an `author` and `description`.
2. Run `bin/setup` (or seed the database) so the flag is created in the `feature_flags_features` table.
3. Check the flag in code with `FeatureFlags::FeatureFlag.active?(:your_flag_name)`.
4. Toggle it via the Support Interface at `/support/features`.

## Current flags

### `check_service_open`

Removes basic HTTP authentication from Check a Teacher's Record. When inactive, all CTR requests are gated behind basic auth (credentials from `SUPPORT_USERNAME` / `SUPPORT_PASSWORD`), which prevents public access on non-production environments. Should always be active on production and inactive on test/preprod.

### `qualifications_service_open`

Removes basic HTTP authentication from Access Your Teaching Qualifications. Same as `check_service_open` but for AYTQ. Should always be active on production and inactive on non-production environments. 

### `support_service_open`

Removes basic HTTP authentication from the Support Interface. When inactive, the Support Interface requires basic auth credentials in addition to DSI sign-in. Should always be active on production and inactive on non-production environments. 

### `manage_roles`

Shows or hides the "Check role codes" section in the Support Interface navigation. When active, internal users can view, create, and edit DSI role codes at `/support/roles`. When inactive, the nav link is hidden (though the routes still exist).

### `bulk_search`

Shows or hides the bulk search option in the CTR navigation. When active, employers can upload a CSV of up to 100 TRN/date-of-birth pairs for batch lookup at `/check-records/bulk-searches`. Checked in `CheckRecords::NavigationComponent`. Note that the bulk search routes and controller remain accessible regardless of the flag state; only the navigation link is gated.

### `trn_search`

Controls the TRN disambiguation flow in CTR search. When active, if a name + date of birth search returns more than one result, the user is redirected to a TRN search page prompting them to enter the teacher's TRN for a more specific lookup. When inactive, search results are shown directly regardless of how many matches are returned.

### `teacher_profile_tags`

Adds a profile summary component to the teacher detail page in CTR. When active, `CheckRecords::TeacherProfileSummaryComponent` is rendered in the right-hand column of the teacher show page, displaying summary tags for the teacher's profile.

### `downtime_banner`

Displays a notification banner across all CTR pages informing users of planned service downtime. This should normally be inactive and only activated during planned downtime windows. The banner message is hardcoded in the CTR layout template, so you'll need to update it before reactivating for a future window.

## Unused flags

These flags are defined in `config/feature_flags.yml` but are not checked anywhere in the application code.

### `malware_scan`

The malware scanning pipeline runs unconditionally whenever a name change or date of birth change request with an attached file is submitted.

### `one_login`

Both authentication providers are registered as OmniAuth middleware simultaneously and both are always available.
