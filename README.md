# Access your teaching certificates

A service that allows people to access their teaching certificates.

## Dependencies

- Ruby 3.x
- Node.js 16.x
- Yarn 1.22.x
- PostgreSQL 13.x
- Redis 6.x

## How the application works

Access your teaching certificates is a monolithic Rails app built with the GOVUK Design System.

The application has a number of different interfaces for different types of users:

### Architecture

We keep track of architecture decisions in [Architecture Decision Records
(ADRs)](/adr/).

We use `rladr` to generate the boilerplate for new records:

```bash
bin/bundle exec rladr new title
```

## Setup

### Bare metal

Install dependencies using your preferred method, using `asdf` or `rbenv` or `nvm`. Example with `asdf`:

```bash
# The first time
brew install asdf # Mac-specific
asdf plugin add azure-cli
asdf plugin add ruby
asdf plugin add nodejs
asdf plugin add yarn
asdf plugin add postgres
asdf plugin add redis

# To install (or update, following a change to .tool-versions)
asdf install
```

If installing PostgreSQL via `asdf`, you may need to set up the `postgres` user:

```bash
pg_ctl start
createdb default
psql -d default
> CREATE ROLE postgres LOGIN SUPERUSER;
```

If the install step created the `postgres` user already, it won't have created one
matching your username, and you'll see errors like:

`FATAL: role "username" does not exist`

So instead run:

```bash
pg_ctl start
createdb -U postgres default
```

You might also need to install `postgresql-libs`:

```bash
sudo apt install libpq-dev
sudo pacman -S postgresql-libs
sudo pamac install postgres-libs
sudo yum install postgresql-devel
sudo zypper in postgresql-devel
```

If installing Redis, you'll need to start it in a separate terminal:

```bash
redis-server
```

Setup the project (re-run after `Gemfile` or `package.json` updates, automatically restarts any running Rails server):

```bash
bin/setup
```

Run the application on `http://localhost:3000`:

```bash
bin/dev
```

### Visit app

Main front end: <http://localhost:3000/>

Admin area: <http://localhost:3000/support>

Admin area login is defined by `ENV['SUPPORT_USERNAME']` and `ENV.fetch["SUPPORT_PASSWORD"]` by default test \ test

### Feature flags

The following feature flags are required for normal operation of the site and are set from seeds.rb as part of `bin/setup`:

```ruby
FeatureFlags::Feature.create(name: :service_open, active: true)
```

### Notify

If you want to test and simulate sending emails locally, you need to be added
to the TRA digital Notify account. Then, go to
`API integration > API keys > Create an API key` and create a new key, such as
`Myname - local test` and set the type to `Test - pretends to send messages`.

Add this key to your local development secrets:

```bash
$ vim .env.development.local
GOVUK_NOTIFY_API_KEY=me__local_test-abcefgh-1234-abcdefgh
```

When you send an email locally, the email should appear in the message log in
the Notify dashboard in the `API integration` section.

_Note:_ You can set `GOVUK_NOTIFY_API_KEY=fake-key` when running locally if you don't need to use Notify.

### Linting

To run the linters:

```bash
bin/lint
```

### Testing

To run the tests (requires Chrome due to
[cuprite](https://github.com/rubycdp/cuprite)):

```bash
bin/test
```

### Intellisense

[solargraph](https://github.com/castwide/solargraph) is bundled as part of the
development dependencies. You need to [set it up for your
editor](https://github.com/castwide/solargraph#using-solargraph), and then run
this command to index your local bundle (re-run if/when we install new
dependencies and you want completion):

```sh
bin/bundle exec yard gems
```

You'll also need to configure your editor's `solargraph` plugin to
`useBundler`:

```diff
+  "solargraph.useBundler": true,
```

### Accessing the Rails console through the Azure CLI

We have a helpful command you can run that will connect you to the right Azure resource.
You will need the [Azure CLI](https://docs.microsoft.com/en-gb/cli) installed and a [PIM (Privileged Identity Management) request](docs/privileged-identity-management-requests.md) for `production`, `preprod` and `test`.

```bash
make dev az-console
make test az-console
make preprod az-console
make production az-console
make review pr_id=<ID> az-console
```

The review app needs to be deployed first. You can do this manually by tagging a PR with the `deploy` label.

### Updating keyvault secrets

Make sure `jq` is [installed](#local-development-dependencies).

```bash
make dev edit-keyvault-secret
make test edit-keyvault-secret
make preprod edit-keyvault-secret
make production edit-keyvault-secret
make review pr_id=<ID> edit-keyvault-secret
```

## Licence

[MIT Licence](LICENCE).
