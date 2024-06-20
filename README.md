# Setup

```
az ad sp create-for-rbac --name "github-membrane-rpm-builder" --role Contributor --scopes /subscriptions/2a5e9a0c-6d1d-49f6-8b2a-96647a511370/resourceGroups/demo --json-auth
```

Go to this Git Repo on Github.
Go to Settings > Secrets and Variables > Actions.
Choose New repository secret, enter name `AZURE_CREDENTIALS` and paste the value of the `az` command as value.

Create another repository secret: name `SSH_PUB_KEY` and enter a line for the authorized_keys file as value.
