#!/bin/bash

jq --help

az --help

jq -Rs --arg SSH_PUB_KEY Tob --arg "$(cat starter-complete.sh)" cust "$(cat myparameters.json)" </dev/null


exit 0

az deployment group create --name addnameparameter --resource-group demo --template-file .\template.json --parameters "@myparameters.json" > data.json


MANAGED_ID=$(cat data.json | jq -r .identity.principalId)

az role assignment create --role "Key Vault Secrets User" --assignee "$MANAGED_ID" --scope /subscriptions/2a5e9a0c-6d1d-49f6-8b2a-96647a511370/resourcegroups/demo/providers/Microsoft.KeyVault/vaults/rpm-builder
