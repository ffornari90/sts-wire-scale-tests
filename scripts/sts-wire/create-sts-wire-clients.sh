#!/bin/bash
ROOTDIR=$(git rev-parse --show-toplevel)
if ! [[ $# -eq 2 ]] ; then
    echo 'ERROR: You must provide a number of clients and an issuer URL.'
    exit 1
fi
IAM_URL=$2
for i in $(seq 1 $1)
do
mkdir -p "$ROOTDIR/scripts/sts-wire/conf/client$i"
echo '{
  "redirect_uris": [
    "https://rgw.cloud.infn.it/"
  ],
  "client_name": "sts-wire-client'$i'",
  "contacts": [
    "federico.fornari@cnaf.infn.it"
  ],
  "token_endpoint_auth_method": "client_secret_basic",
  "scope": "address phone openid email profile offline_access eduperson_scoped_affiliation eduperson_entitlement wlcg wlcg.groups",
  "grant_types": [
    "refresh_token",
    "authorization_code"
  ],
  "response_types": [
    "code"
  ]
}' | \
tee "$ROOTDIR/scripts/sts-wire/conf/client$i/client-req.json"
http $IAM_URL/iam/api/client-registration \
 < "$ROOTDIR/scripts/sts-wire/conf/client$i/client-req.json" \
 > "$ROOTDIR/scripts/sts-wire/conf/client$i/client.json"
done
