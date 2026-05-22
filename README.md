# Access your teaching qualifications & Check a teacher's record

This repo is home to two services:

- **Access Your Teaching Qualifications (AYTQ)** — a service that allows teachers to view their teaching qualifications, download certificates, and request changes to their personal details.
- **Check a Teacher's Record (CTR)** — a service that allows employers, providers, and local authorities to search for and view teacher records.

Both services are monolithic Rails apps built with the GOV.UK Design System. They share a single repository, database, and deployment pipeline but are accessible from distinct URLs in production.

## Quick start

```bash
bin/setup    # Install dependencies, set up database, seed data
bin/dev      # Start the application on http://localhost:3000
```

See the [full setup guide](docs/setup.md) for dependencies, installation, PostgreSQL and Redis configuration, and troubleshooting.

## Live environments

### AYTQ

| Name       | URL      |
| ---------- | -------- |
| Production | Deployed |
| Preprod    | Deployed |
| Test       | Deployed |

### Check

| Name       | URL      |
| ---------- | -------- |
| Production | Deployed |
| Preprod    | Deployed |
| Test       | Deployed |

All environments have continuous deployment, the state of which can be inspected in Github Actions.

| Name       | Description                                   |
| ---------- | --------------------------------------------- |
| Production | Public site                                   |
| Preprod    | For internal use by DfE to test deploys       |
| Test       | For external use by 3rd parties to run audits |

## Documentation

### Getting started

- [Setup guide](docs/setup.md) — installing dependencies, project setup, and accessing the app locally
- [Local development](docs/local_development.md) — feature flags, GOV.UK Notify, BigQuery, linting, testing, and IDE setup
- [Routing two services](docs/routing-two-services.md) — how AYTQ and Check coexist in one Rails app with distinct hostnames

### Architecture

- [Architecture overview](docs/architecture.md) — C4 diagrams and Architecture Decision Records
- [Data schema](docs/data_schema.md) — database tables and which service uses each

### Infrastructure & operations

- [Deployment](docs/deployment.md) — CI/CD pipeline and troubleshooting
- [Review apps](docs/review_apps.md) — deploying and using review apps
- [Operations](docs/operations.md) — Rails console access and keyvault secret management
- [Azure storage](docs/azure_storage.md) — evidence upload storage configuration
- [Encryption](docs/encryption.md) — ActiveRecord Encryption and key rotation
- [Disaster recovery](docs/disaster_recovery.md) — database failure scenarios and recovery procedures

### Maintenance

- [Updating Ruby](docs/updating_ruby.md) — where to update the Ruby version and downstream impacts
- [Puppeteer](docs/puppeteer.md) — Chromium/Puppeteer configuration for certificate PDF generation
- [Testing styleguide](docs/testing_styleguide.md) — conventions for feature and unit tests

## Infrastructure validation workflow

The scheduled workflow defined in `.github/workflows/validate-infra.yml` runs Terraform plan validations for the AKS cluster plus domains infrastructure/environment each day at **07:00 UTC** against **production** only. Failures and drift notifications are sent to the SD Infra alerts Teams channel via the `TEAMS_WEBHOOK_URL_INFRA` secret.

## Licence

[MIT Licence](LICENCE).
