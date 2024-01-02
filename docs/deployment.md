# Deployment

The services are automatically deployed via a [Github action](https://github.com/DFE-Digital/access-your-teaching-qualifications/actions/workflows/build-and-deploy.yml) when a branch is merged to main.

We deploy across four environments:

- dev
- test
- preprod
- production

Production will only deploy when the non-production deploys were all successful.

## Troubleshooting

- "State blob is already locked": sometimes the terraform state file lock can get stuck which will prevent subsequent deploys to that environment from succeeding.
  - Make sure there are no other deploys in progress that have a valid lock on the file
  - In the azure portal, navigate to the correct resource group for the environment
  - In the resources list, open the `<rg>aytqtfstate<env>` storage account
  - Navigate to 'Containers'
  - Open the `aytq-tfstate` container
  - Select the state file and right-click 'Break lease'
