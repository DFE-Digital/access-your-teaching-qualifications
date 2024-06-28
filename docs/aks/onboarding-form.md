# Teacher services infra - Service onboarding form

Note - this is a migration of two existing services. They share a single codebase, are served to the public from
two different domains, and are currently deployed to (non-AKS) Azure.

- Service name? Access your teaching qualifications / Check a teacher's record (two services, single codebase)
- Domains ?
  - access-your-teaching-qualifications.education.gov.uk (already exists)
  - check-a-teachers-record.education.gov.uk (already exists)
  - access-your-teaching-qualifications.teacherservices.cloud
  - check-a-teachers-record.teacherservices.cloud
  - test._ and preprod._ variants of the above.
- Service short name? aytq
- Repository? https://github.com/DFE-Digital/access-your-teaching-qualifications/
- Environments? e.g. develoment, staging, production
  - test
  - preprod
  - production
- Review apps? Yes or No
  - Yes
- Cost centre/Activity code ? e.g. 10167/101304
  - Unknown
- List of developers who will need access to Azure? Do they use a DfE laptop or BYOD? e.g
  - Felix Clack - BYOD
  - James Gunn - BYOD
  - Richard Pattinson - DfE laptop
- GDS assessed? Yes or No
  - Yes
- Slack channels? e.g
  - Product: #tra_digital
  - Tech: #tra_developers
- Timeline? When is each environment needed? What are the planned project phases?
  - No specific timeline, will be working on Review apps first with assistance from infra team, followed by test/preprod/production.
- Github repos / Docker registry type: Open (public) by default, or indicate any requirement to make them private
  - Open
- Namespaces e.g. bat-qa (test cluster), bat-staging (test cluster), bat-production (production cluster)
  - tra-development (for review)
  - tra-test (for test/preprod)
  - tra-production (for production)
- Technical requirements
  - Ruby on rails webapp
  - postgres
  - redis for sidekiq
  - DNS setup that matches existing configuration, ie - two different domains pointing to the same running app
  - Azure storage for each environment
- Healthcheck page
  - /health
