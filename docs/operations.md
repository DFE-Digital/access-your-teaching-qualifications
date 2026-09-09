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

## Running a rake task

Same access as the console above. `railstask` runs a task in a deployed pod rather than opening a
shell.

```bash
make test railstask TASK=pii:verify
make production railstask TASK=pii:verify
```

Quote the task if it takes an argument, or zsh reads the brackets as a glob:

```bash
make production railstask TASK='pii:re_encrypt[User:12345]'
```

`WORKER=1` runs against the sidekiq deployment instead of the web one, for when the web deployment
is scaled to zero:

```bash
make production railstask WORKER=1 TASK=pii:re_encrypt
```

## Updating keyvault secrets

Updating keyvault secrets is a manual process which will require elevated permissions via PIM for production access to Azure resources, the resource can be found in:

```
Review: s189t01-aytq-rv-app-kv
Test: s189t01-aytq-ts-app-kv
Preproduction: s189t01-aytq-pp-inf-kv
Production: s189p01-aytq-pd-app-kv
```
