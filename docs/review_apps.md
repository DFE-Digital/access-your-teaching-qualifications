# Review apps

Like other services at DfE, both Access your teaching qualifications (AYTQ) and Check a teacher’s record (Check) have support for review apps. Adding the 'deploy' label to a PR will start the process of creating a review app. Its URL will be posted in a PR comment once it's running.

Both services are accessible at the single URL. By default, the base path will redirect to AYTQ. The Check service is available by manually entering one of its routes (eg - `/check-records/sign-in`). The routes for both services are namespaced (`/qualifications` and `/check-records`, respectively), helping to ensure that their routes are distinct. The review app relies on this distinctness to work correctly - we'd have to implement service-specific review apps if conflicting routes were ever introduced.

## Deployment

In order to deploy a review app you can either use the make target or raise a pull request and label the deployment with 'deploy-aks' and this will trigger the GHA workflow to deploy the review app based on the branch name.

This will then create a URL for testing and to destroy the review app when you close the pull request which will trigger the delete workflow. Further details for this can be found in the github workflow build-and-deploy.yml as well as the deploy-environment/action.yml.

Note that review apps have container based Postgres and Redis volumes. The data will not persist once the review app has been destroyed.

## Authentication

Each service interacts with the Qualifications API in a different way:

- AYTQ requires a user-specific token, issued on Identity sign in
- Check uses a fixed token

As such, each service handles signing into an account differently as well:

- AYTQ uses the full Identity auth flow. This requires an Identity account in preprod.
- Check uses an auth bypass. When accessing the Check sign in page on a review app, a button press lets you sign in with a test user.
