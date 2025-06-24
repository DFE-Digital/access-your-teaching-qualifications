# Updating Ruby

## Places you need to update

- The Ruby version in the `Gemfile` (remember to run `bundle install`)
- The base image being used for both the builder and production steps in `Dockerfile`
- The Ruby version in `.ruby-version`
- The Ruby version in `.tool-versions`

## Other dependencies that need upgrading

### Puppeteer

Puppeteer requires that the version of Chromium being installed matches to the version of puppeteer being installed, this means that when you upgrade the base image of the Dockerfile, which will most likely upgrade your base alpine image, you will also need to update the version of puppeteer in the `package.json` file.

See [docs/puppeteer.md](docs/puppeteer.md) for more information on how to do this.
