#!/bin/bash

#
# PLEASE EDIT starter.sh, NOT starter-complete.sh AND EXECUTE ./pre-generate.sh BEFORE COMMITTING.
#

echo 3 > /demo3.txt

cd /root

cat >background.sh <<'EOF2'
$DATA
EOF2

chmod +x background.sh

nohup /bin/bash -c './background.sh "$VERSION"' >log.txt 2>&1 &