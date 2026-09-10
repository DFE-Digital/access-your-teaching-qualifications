# Deployment

The services are automatically deployed via a [Github action](https://github.com/DFE-Digital/access-your-teaching-qualifications/actions/workflows/build-and-deploy.yml) when a branch is merged to main.

We deploy across three environments (test, preprod, and production). See the [README](../README.md#live-environments) for environment URLs and descriptions. Production will only deploy when the non-production deploys were all successful.

## Troubleshooting

- "State blob is already locked": sometimes the terraform state file lock can get stuck which will prevent subsequent deploys to that environment from succeeding.
  - Make sure there are no other deploys in progress that have a valid lock on the file
  - In the azure portal, navigate to the correct resource group for the environment
  - In the resources list, open the `<rg>aytqtfstate<env>` storage account
  - Navigate to 'Containers'
  - Open the `aytq-tfstate` container
  - Select the state file and right-click 'Break lease'

## Deploying while the maintenance page is up

Every deploy is a terraform apply, and the apply rewrites both public ingresses from the
environment's tfvars. By default that points them at the app, which takes the maintenance page down
part way through the deploy. Set `send_traffic_to_maintenance_page` to `true` in
`terraform/application/config/<env>.tfvars.json` on the branch being deployed and the apply points
the ingresses at the maintenance service instead.

To bring the app back, set it to `false` and deploy: that apply resets the ingresses. Then run the
maintenance workflow in `disable` mode to delete the maintenance deployment and the temp ingresses.
Running `disable` on its own also resets the ingresses, but the next apply undoes that while the
flag is still `true`.
