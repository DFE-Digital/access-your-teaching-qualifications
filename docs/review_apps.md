# Review apps

Like other services at DfE, both Access your teaching qualifications (AYTQ) and Check a teacher’s record (Check) have support for review apps. Adding the 'deploy' label to a PR will start the process of creating a review app. Its URL will be posted in a PR comment once it's running.

Both services are accessible at the single URL. By default, the base path will redirect to AYTQ. The Check service is available by manually entering one of its routes (eg - `/check-records/sign-in`). The routes for both services are namespaced (`/qualifications` and `/check-records`, respectively), helping to ensure that their routes are distinct. The review app relies on this distinctness to work correctly - we'd have to implement service-specific review apps if conflicting routes were ever introduced.

## Deployment

In order to deploy a review app you can either use the make target or raise a pull request and label the deployment with 'deploy' and this will trigger the GHA workflow to deploy the review app based on the branch name.

This will then create a URL for testing and to destroy the review app when you close the pull request which will trigger the delete workflow. Further details for this can be found in the github workflow build-and-deploy.yml as well as the deploy-environment/action.yml.

Note that review apps have container based Postgres and Redis volumes. The data will not persist once the review app has been destroyed.

## Authentication

Each service authenticates differently on review apps. AYTQ uses the full auth flow (requiring an account in preprod), while Check uses an auth bypass — a button on the sign-in page lets you sign in with a test user.

For details on how each service authenticates with the Qualifications API, see [AYTQ authentication](authentication/aytq/readme.md) and the [Qualifications API integration guide](api_integrations/qualifications_api.md#authentication-modes).
