#!/bin/bash

export DATA=$(cat background.sh)
cat starter.sh | envsubst | base64 | tr -d '\r\n' > starter-complete.sh
