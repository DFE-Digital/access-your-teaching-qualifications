# Qualifications API Integration

The Qualifications API (also referred to as the TRS API or Teacher Qualifications API) is an external API maintained by the Teaching Record System (TRS) team. It's the primary data source for teacher records in this application. Neither AYTQ nor CTR store teacher qualification data locally — both services fetch it on demand from this API.

The API provides endpoints for fetching a teacher's full record (qualifications, induction status, sanctions/alerts, pending changes), searching for teachers by last name and date of birth, bulk searching by TRN and date of birth, downloading qualification certificates as PDFs, and submitting name change and date of birth change requests on behalf of teachers.

There's also a separate NPQ Qualifications API (hosted by the NPQ Registration service) that provides National Professional Qualification data. This is consumed alongside the main Qualifications API — see the "NPQ API companion" section below.

## Configuration

The client is configured via environment variables:

| Variable                             | Purpose                                                    |
| ------------------------------------ | ---------------------------------------------------------- |
| `QUALIFICATIONS_API_URL`             | Base URL of the Qualifications API                         |
| `QUALIFICATIONS_API_FIXED_TOKEN`     | Fixed Bearer token for server-to-server auth (used by CTR) |
| `NPQ_QUALIFICATIONS_API_URL`         | Base URL of the NPQ Qualifications API                     |
| `NPQ_QUALIFICATIONS_API_FIXED_TOKEN` | Fixed Bearer token for the NPQ API                         |

Default values for development and test are set in `.env.development` and `.env.test`. Production values are managed via Azure Key Vault. The Faraday client uses a 30-second timeout and is configured with JSON request/response middleware and Bearer token authorization.

The integration lives in `app/lib/qualifications_api/`. `QualificationsApi::Client` is the Faraday-based HTTP client that wraps all API calls, `QualificationsApi::Teacher` is the domain model that wraps raw API JSON into a rich object with qualification, status, and sanction logic, and `QualificationsApi::Certificate` represents a downloaded PDF certificate. The companion NPQ integration lives in `app/lib/npq_qualifications_api/` with its own `Client` and `GetQualificationsForTeacher` service object.

## API versioning

The Qualifications API uses a versioned header (`X-Api-Version`) to control which response shape is returned. Different endpoints use different versions:

| Endpoint                                                      | API Version |
| ------------------------------------------------------------- | ----------- |
| `v3/person`, `v3/persons/:trn`                                | `20250627`  |
| `v3/persons` (search)                                         | `20250327`  |
| `v3/persons/find` (bulk search)                               | `20250627`  |
| `v3/teacher/name-changes`, `v3/teacher/date-of-birth-changes` | `20240416`  |

## Authentication modes

The same `Client` class is used by both halves of the application but with different authentication tokens depending on the context.

**AYTQ (teacher-facing) — user token auth:** When a teacher signs in via One Login or DfE Identity, the auth flow issues a user-specific JWT. This token is stored in `current_session.user_token` and passed to the client. The API uses this token to identify which teacher's record to return, so the `v3/person` endpoint (no TRN) is used — the API resolves the teacher from the token itself.

```ruby
# In AYTQ controllers
client = QualificationsApi::Client.new(token: current_session.user_token)
@teacher = client.teacher  # no TRN needed, resolved from token
```

**CTR (employer-facing) — fixed token auth:** When an employer signs in via DfE Sign In, the application uses a fixed server-to-server Bearer token from `ENV["QUALIFICATIONS_API_FIXED_TOKEN"]`. Because this token isn't teacher-specific, the TRN must be provided explicitly to look up a specific teacher's record.

```ruby
# In CTR controllers
client = QualificationsApi::Client.new(token: ENV["QUALIFICATIONS_API_FIXED_TOKEN"])
@teacher = client.teacher(trn: trn)  # TRN required with fixed token
```

## The Teacher model

`QualificationsApi::Teacher` wraps the raw API JSON and adds domain logic for:

- **Qualification assembly:** Aggregates qualifications from multiple sources (QTS, EYTS, NPQ, mandatory qualifications, induction, and routes to professional status) into a single ordered list.
- **Teaching status resolution:** Determines the teacher's overall status (QTS, EYTS, EYPS, QTS via QTLS, etc.) based on a combination of fields.
- **Induction status:** Resolves induction status using a priority order: Failed > Exempt > Passed > RequiredToComplete > InProgress > FailedInWales > None. Exemption can come from either an explicit status or active QTLS membership.
- **Sanctions and alerts:** Filters the raw alerts list to only show active, recognised sanction types.
- **Pending changes:** Tracks whether a name or date of birth change request is in progress.

### NPQ API companion

The NPQ Qualifications API is a separate service that provides National Professional Qualification data, consumed via `NpqQualificationsApi::Client` and `NpqQualificationsApi::GetQualificationsForTeacher`.
