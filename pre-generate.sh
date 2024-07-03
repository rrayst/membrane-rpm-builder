#!/bin/bash

export DATA=$(cat background.sh | tr -d '\r')
cat starter.sh | tr -d '\r' | envsubst | base64 | tr -d '\r\n' > starter-complete.sh
