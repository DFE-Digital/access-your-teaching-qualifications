# 5. Replace Devise with DSI OAuth for support users

Date: 2024-02-20

## Status

Accepted

## Context

Support user access to the service should be managed via the DfE Sign In (DSI) OAuth provider. Organisation level policies, roles and user access are centralised in DSI and allow us to administer access in one place.
Orignally Devise was used as the authentication mechanism for support users, this meant duplication and arguably lower levels of security as the service was responsible for authentication, and user details were stored in the same database as other records.

## Decision

Authenticate support users via DSI.

## Consequences

We are reliant on the DSI team for some policy and role setup. We are also reliant on the stability of the DSI service.
