# Review apps

Like other services at DfE, both Access your teaching qualifications (AYTQ) and Check a teacher’s record (Check) have support for review apps. Adding the 'deploy' label to a PR will start the process of creating a review app. Its URL will be posted in a PR comment once it's running.

Both services are accessible at the single URL. By default, the base path will redirect to AYTQ. The Check service is available by manually entering one of its routes (eg - `/check-records/sign-in`). The routes for both services are namespaced (`/qualifications` and `/check-records`, respectively), helping to ensure that their routes are distinct. The review app relies on this distinctness to work correctly - we'd have to implement service-specific review apps if conflicting routes were ever introduced.

## Deployment

Pending a migration to AKS, the current process for provisioning a review app can be lengthy and somewhat unstable. The build and deploy action can fail for a number of reasons, as can the deployed app. This includes:

- The slot swap that happens as part of the deployment can fail because the new service fails to respond to a ping
- The new service may not have its database created properly, resulting in missing table errors in the running app

Retrying the Github action usually resolves these issues, and subsequent deploys of the review app are generally faster and more reliable.

For troubleshooting, logs are available in both Github Actions and Logit.

## Authentication

Each service interacts with the Qualifications API in a different way:

- AYTQ requires a user-specific token, issued on Identity sign in
- Check uses a fixed token

As such, each service handles signing into an account differently as well:

- AYTQ uses the full Identity auth flow. This requires an Identity account in preprod.
- Check uses an auth bypass. When accessing the Check sign in page on a review app, a button press lets you sign in with a test user.
