# Setup

## Dependencies

- Ruby 3.4.4
- Node.js 19.6.0
- Yarn 1.22.19
- PostgreSQL 13.5
- Redis 6.2.13

## Installing dependencies

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

### PostgreSQL

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

### Redis

If installing Redis, you'll need to start it in a separate terminal:

```bash
redis-server
```

## Project setup

Setup the project (re-run after `Gemfile` or `package.json` updates, automatically restarts any running Rails server):

```bash
bin/setup
```

Run the application on `http://localhost:3000`:

```bash
bin/dev
```

## Accessing the application locally

Main front end: <http://localhost:3000/>

Admin area: <http://localhost:3000/support>

Admin area login is defined by `ENV['SUPPORT_USERNAME']` and `ENV.fetch("SUPPORT_PASSWORD")`, by default test / test.

Both services are accessible from the same local server. AYTQ is available at `http://localhost:3000` and Check is available at `http://check.localhost:3000`. See [routing two services](routing-two-services.md) for more details.
