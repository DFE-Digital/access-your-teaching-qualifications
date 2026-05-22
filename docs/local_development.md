# Local Development

## Feature flags

The following feature flags are required for normal operation of the site and are set from seeds.rb as part of `bin/setup`:

```ruby
FeatureFlags::Feature.create(name: :service_open, active: true)
```

## GOV.UK Notify

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

## BigQuery

Edit `.env.development.local` and add a BigQuery key if you want to use BigQuery locally.

See [DfE Analytics](https://github.com/DFE-Digital/dfe-analytics#2-get-an-api-json-key-key) for information on how to get a key.

You also need to set `BIGQUERY_DISABLE` to `false` as it defaults to `true` in the development environment.

[Read more about setting up BigQuery](https://github.com/DFE-Digital/dfe-analytics/blob/main/docs/google_cloud_bigquery_setup.md).

## Linting

To run the linters:

```bash
bin/lint
```

## Testing

To run the tests (requires Chrome due to [cuprite](https://github.com/rubycdp/cuprite)):

```bash
bin/test
```

See the [testing styleguide](testing_styleguide.md) for conventions on writing tests.

## Intellisense

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
