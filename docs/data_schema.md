# Data Schema

The [database schema](https://github.com/DFE-Digital/access-your-teaching-qualifications/blob/main/db/schema.rb) follows general Rails conventions. While the database is shared between two services, most tables are used by only one of the services. The distinction is important when we're looking at the BigQuery analytics as, unlike the web requests, the entity events that we send aren't namespaced.

## Access your teaching qualifications

- users: Users that have logged into the service using their DfE Teaching Id
- active_storage\_\*: these tables relate to file attachments created when a user downloads their certificate

## Check a teacher's record

- dsi_user_sessions: created with each new user session when a user logs in via DfE Signin. This table includes the organisation that the user has logged in on behalf of and the role that they logged in with.
- dsi_users: the user details of users that have logged in via DfE Signin
- feedbacks: feedback given using the feedback form (AYTQ currently uses an MS Form)
- search_logs: created on each search

The other tables aren't currently relevant to analytics.
