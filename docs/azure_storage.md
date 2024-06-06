# Azure Storage

We've implemented a feature in AYTQ that allows users to upload evidence in order to request a change to their name or date of birth on the Teacher Record Service.

We store evidence uploads in Azure Storage. Each environment has a storage account set up for it:

| Environment | Storage account name  |
| ----------- | --------------------- |
| Dev         | s165d01aytqevidencedv |
| Test        | s165d01aytqevidencets |
| Preprod     | s165d01aytqevidencepp |
| Production  | s165p01aytqevidencepd |

These can be viewed in the Azure Portal. Each storage account has a container called 'uploads' which contains the evidence files uploaded by users.

We use ActiveStorage to read/write to these containers. In production ActiveStorage is configured to use the `microsoft` service. See:

```
config/storage.yml
config/environments/production.rb
```

These are the environment variables that need to be set in order to access an Azure storage account:

```
AZURE_STORAGE_ACCOUNT_NAME
AZURE_STORAGE_ACCESS_KEY
AZURE_STORAGE_CONTAINER
```

## Local development

In the development and test Rails environments, ActiveStorage is configured by default to use the `local` and `test` services, respectively. These both write to disk. See `storage.yml` for directory paths.

## Manual testing

To test uploads to Azure in your local dev environment, do the following:

- In `development.rb`, change `config.active_storage.service = :local` to `:microsoft`
- In .env.development.local, set the following environment variables:
  ```
  AZURE_STORAGE_ACCOUNT_NAME=s165d01aytqevidencedv
  AZURE_STORAGE_ACCESS_KEY={retrieve from Azure Portal}
  AZURE_STORAGE_CONTAINER=uploads
  ```
- Restart your server
- Carry out a file upload, eg - by completing the name change form on the account page
