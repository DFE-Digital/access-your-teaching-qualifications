# Routing two services

This repo contains both the Check and AYTQ services.

In production, each service is accessible from its own distinct URL. Following
a similar patten to [Publish Teacher
Training](https://github.com/DFE-Digital/publish-teacher-training/), we
implement this using route constraints in config/routes.rb.

AYTQ-specific routes are only accessible if the request comes from an AYTQ
hostname. The same goes for Check. The Rails app needs to be configured
explicitly with these hostnames - see the environment variables referenced in
HostingEnvironment.

## Local development

For redirects and root paths to work correctly in local development, it's
useful to access the two services via distinct hostnames. There are a number of
ways to achieve this, but the recommended way is as follows:

1. Start the server.
2. Access AYTQ via http://localhost:3000
3. Access Check via http://check.localhost:3000

The .env.development file is pre-configured with the hostnames above.
