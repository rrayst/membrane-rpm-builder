#!/bin/bash

VERSION="$1"
SSH_PUB_KEY="$2"

if [ "$VERSION" = "" -o "$SSH_PUB_KEY" = "" ] ; then
	echo "Parameters: $0 <version> <ssh-public-key>"
	exit 1
fi


jq -Rs \
--arg SSH_PUB_KEY "$SSH_PUB_KEY" \
--arg CUSTOM_DATA "$(cat starter-complete.sh)" \
--arg USER_DATA "$(echo $VERSION | base64)" \
"$(cat myparameters.json)" \
</dev/null

az deployment group create --name addnameparameter --resource-group demo --template-file .\template.json --parameters "@myparameters.json" > data.json


MANAGED_ID=$(cat data.json | jq -r .identity.principalId)

az role assignment create --role "Key Vault Secrets User" --assignee "$MANAGED_ID" --scope /subscriptions/2a5e9a0c-6d1d-49f6-8b2a-96647a511370/resourcegroups/demo/providers/Microsoft.KeyVault/vaults/rpm-builder
