# Operations

## Accessing the Rails console

We have a helpful command you can run that will connect you to the right Azure resource.
You will need the [Azure CLI](https://docs.microsoft.com/en-gb/cli) installed and a PIM (Privileged Identity Management) request for `production`, `preprod` and `test`.

```bash
make test railsc
make preprod railsc
make production railsc
make review railsc PR_NUMBER=<PR_NUMBER>
```

The review app needs to be deployed first. You can do this manually by tagging a PR with the `deploy` label.

## Updating keyvault secrets

Updating keyvault secrets is a manual process which will require elevated permissions via PIM for production access to Azure resources, the resource can be found in:

```
Review: s189t01-aytq-rv-app-kv
Test: s189t01-aytq-ts-app-kv
Preproduction: s189t01-aytq-pp-inf-kv
Production: s189p01-aytq-pd-app-kv
```
