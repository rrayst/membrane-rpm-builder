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
>myparameters2.json </dev/null

az deployment group create --name addnameparameter --resource-group demo --template-file template.json --parameters "@myparameters2.json" > data.json
