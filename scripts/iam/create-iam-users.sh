#!/bin/bash
if ! [[ $# -eq 3 ]] ; then
    echo 'ERROR: You must provide a number of clients, an OIDC admin client name and an issuer URL.'
    exit 1
fi
NUM_CLIENTS=$1
OIDC_ADMIN_CLIENT=$2
IAM_URL=$3
for i in $(seq 1 $NUM_CLIENTS)
do
  index=$(printf "%02d" $i)
  cat > payload.json <<EOF
{
  "schemas": ["urn:ietf:params:scim:schemas:core:2.0:User", "urn:indigo-dc:scim:schemas:IndigoUser"],
  "userName": "client${i}",
  "active": true,
  "name": {
    "familyName": "${index}",
    "givenName": "Client"
  },
  "emails": [{
    "value": "client${i}@cnaf.infn.it",
    "type": "work",
    "primary": true
  }]
}
EOF
  TOKEN=$(oidc-token $OIDC_ADMIN_CLIENT)
  curl -s -X POST -H 'Content-type: application/scim+json' -H "Authorization: Bearer $TOKEN" -d @payload.json $IAM_URL/scim/Users | jq '.'
done
