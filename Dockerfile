# This template builds two images, to optimise caching:
# builder: builds gems and node modules
# production: runs the actual app

# Build builder image
FROM ruby:3.4.4-alpine3.20 AS builder

# RUN apk -U upgrade && \
#     apk add --update --no-cache gcc git libc6-compat libc-dev make nodejs \
#     postgresql13-dev yarn

WORKDIR /app

# Add the timezone (builder image) as it's not configured by default in Alpine
RUN apk add --update --no-cache tzdata && \
    cp /usr/share/zoneinfo/Europe/London /etc/localtime && \
    echo "Europe/London" > /etc/timezone

# build-base: dependencies for bundle
# yarn: node package manager
# postgresql-dev: postgres driver and libraries
RUN apk add --no-cache build-base yarn postgresql15-dev git yaml-dev

# Install gems defined in Gemfile
COPY .ruby-version Gemfile Gemfile.lock ./

# Install gems and remove gem cache
RUN bundler -v && \
    bundle config set no-cache 'true' && \
    bundle config set no-binstubs 'true' && \
    bundle config set without 'development test' && \
    bundle install --retry=5 --jobs=4 && \
    rm -rf /usr/local/bundle/cache

# Install node packages defined in package.json
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile --check-files

# Copy all files to /app (except what is defined in .dockerignore)
COPY . .

# Precompile assets
RUN DATABASE_PASSWORD=required-to-run-but-not-used \
    DFE_SIGN_IN_ISSUER=required-to-run-but-not-used \
    GOVUK_NOTIFY_API_KEY=required-to-run-but-not-used \
    HOSTING_DOMAIN=required-to-run-but-not-used \
    RAILS_ENV=production \
    SECRET_KEY_BASE=required-to-run-but-not-used \
    IDENTITY_API_DOMAIN=required-to-run-but-not-used \
    IDENTITY_CLIENT_ID=required-to-run-but-not-used \
    IDENTITY_CLIENT_SECRET=required-to-run-but-not-used \
    RAILS_SERVE_STATIC_FILES=true \
    bundle exec rails assets:precompile

# Cleanup to save space in the production image
RUN rm -rf log/* tmp/* /tmp && \
    rm -rf /usr/local/bundle/cache && \
    rm -rf .env && \
    find /usr/local/bundle/gems -name "*.c" -delete && \
    find /usr/local/bundle/gems -name "*.h" -delete && \
    find /usr/local/bundle/gems -name "*.o" -delete && \
    find /usr/local/bundle/gems -name "*.html" -delete

# Build runtime image
FROM ruby:3.4.4-alpine3.20 AS production

# The application runs from /app
WORKDIR /app

ENV RAILS_ENV=production

# Add the timezone (prod image) as it's not configured by default in Alpine
RUN apk add --update --no-cache tzdata && \
    cp /usr/share/zoneinfo/Europe/London /etc/localtime && \
    echo "Europe/London" > /etc/timezone

# libpq: required to run postgres
RUN apk add --no-cache libpq

# Copy files generated in the builder image
COPY --from=builder /app /app
COPY --from=builder /usr/local/bundle/ /usr/local/bundle/

# Add the commit sha to the env
ARG COMMIT_SHA
ENV GIT_SHA=$COMMIT_SHA
ENV SHA=$GIT_SHA

# Set up puppeteer (for PDF generation)
# https://pptr.dev/troubleshooting#running-on-alpine
# Install system deps
# Install runtime dependencies
RUN apk add --no-cache \
    nss \
    freetype \
    harfbuzz \
    ca-certificates \
    ttf-freefont \
    nodejs \
    yarn \
    udev \
    dumb-init \
    curl \
    chromium=131.0.6778.108-r0

ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

CMD bundle exec rails db:migrate:ignore_concurrent_migration_exceptions && \
    bundle exec rails data:migrate:ignore_concurrent_migration_exceptions && \
    bundle exec rails server -b 0.0.0.0
