# 4. Implement the Check records service as part of AYTQ

Date: 2023-05-18

## Status

Accepted

## Context

We're building a service that allows employers to check the record of a
teacher. They will be able to search by TRN and view, among other things, an
overview of a teacher's qualifications.

The Access your teaching qualifications service does a similar thing, providing
a view of the same data to a logged in teacher. The primary difference is that
AYTQ only shows information related to the authenticated teacher, whereas an
employer signed in to the Check records service can retrieve the record of any
teacher by TRN.

The overlap in functionality is significant enough that we could consider these
services to be two sides of the same application. There's a strong case for implementing
them in the same codebase.

## Decision

Implement the Check records service in the AYTQ codebase.

## Consequences

- Lots of scope for code reuse, especially around interactions with the DQT API and rendering qualifications on the page
- There's the potential for making the codebase harder to understand
  - We should namespace Check code wherever it makes sense to do so, keeping the separation between the two services fairly obvious
- We'll need to take some extra steps in our routing logic to make two services available at two different domains, but implemented in the same Rails app
  - [Publish teacher training](https://github.com/DFE-Digital/publish-teacher-training) has done this already - we can reuse some of its techniques in AYTQ/Check
