#!/bin/bash

set -xe

VERSION="$1"

if [ "$VERSION" = "" ] ; then
	echo "Parameters: $0 <version>"
	exit 1
fi

while true ; do
        TOKEN=$(curl -q -H 'Metadata: true' 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://vault.azure.net'  | jq -r .access_token)
        curl -H "Authorization: Bearer $TOKEN" "https://rpm-builder.vault.azure.net/secrets/pem/?api-version=7.4" > secret.json
        SEC=$(cat secret.json | jq -r .value)
        echo "SEC: $SEC"
        if [ "$SEC" != "null" ] ; then break ; fi
        sleep 10
done

echo "$SEC" > pem
sed -i -E 's/-  /-\n/g' pem
sed -i -E 's/ -/\n-/g' pem
sed -i -E 's/ =/\n=/g' pem

curl -H "Authorization: Bearer $TOKEN" "https://rpm-builder.vault.azure.net/secrets/zip-release-signing/?api-version=7.4"  | jq -r .value > public
sed -i -E 's/- /-\n/g' public
sed -i -E 's/ -/\n-/g' public
sed -i -E 's/ =/\n=/g' public

set +e
gpg --import public
set -e

GITTOKEN=$(curl -H "Authorization: Bearer $TOKEN" "https://rpm-builder.vault.azure.net/secrets/gittoken/?api-version=7.4"  | jq -r .value)
GITUSER=$(curl -H "Authorization: Bearer $TOKEN" "https://rpm-builder.vault.azure.net/secrets/gituser/?api-version=7.4"  | jq -r .value)

curl -L -o membrane.spec https://raw.githubusercontent.com/membrane/api-gateway/master/membrane.spec
sed -i -E "s/(Version:\s+).*\$/\1$VERSION/" membrane.spec
sed -i -E "s/wget https/wget -O 2FB0F3ED57EF0A8A9CE847C18A006E355B8A65F6.asc https/" membrane.spec
mkdir -p /root/rpmbuild/SRPMS
rpmbuild -bs membrane.spec
rpmbuild --rebuild /root/rpmbuild/SRPMS/membrane-*.el8.src.rpm

set +e
gpg --import pem
set -e

export KEY=$(gpg --list-secret-keys | grep -A1 '^sec' | awk '/[0-9A-Fa-f]{16}/{print $1}')
echo "%_signature gpg
%_gpg_name $KEY" > /root/.rpmmacros
rpm --addsign ./rpmbuild/RPMS/x86_64/membrane-*.x86_64.rpm
cd /root/membrane.github.io
git pull
cp -n /root/rpmbuild/RPMS/x86_64/membrane-*.x86_64.rpm /root/membrane.github.io/rpm/unstable/el8/packages
createrepo  /root/membrane.github.io/rpm/unstable/el8/packages
gpg --yes --detach-sign --armor /root/membrane.github.io/rpm/unstable/el8/packages/repodata/repomd.xml
git add .

cat >>.git/config <<'EOF'
[user]
        name = Tobias Polley
        email = polley@predic8.de
EOF

git commit -m "Published $VERSION"
git push "https://${GITUSER}:${GITTOKEN}@github.com/membrane/membrane.github.io.git"
