#!/bin/bash
ROOTDIR=$(git rev-parse --show-toplevel)
if ! [[ $# -eq 2 ]] ; then
    echo 'ERROR: You must provide a number of clients and an issuer URL.'
    exit 1
fi
OIDC_CLIENT_NUMBER=$1
IAM_URL=$2

IAM_FQDN=$(echo $IAM_URL | awk -F 'https://' '{print $2}')

for i in $(seq 1 $OIDC_CLIENT_NUMBER); do
  CLIENT_PATH="$ROOTDIR/scripts/sts-wire/conf/client$i/client.json"
  CLIENT_ID=$(cat $CLIENT_PATH | jq -r '.client_id')
  CLIENT_SECRET=$(cat $CLIENT_PATH | jq -r '.client_secret')
  REDIRECT_URI=$(cat $CLIENT_PATH | jq -r '.redirect_uris[0]')
  X509_USER_CERT="${ROOTDIR}/scripts/sts-wire/conf/certs/client$i/public.crt"
  X509_USER_KEY="${ROOTDIR}/scripts/sts-wire/conf/certs/client$i/private.key"
  $ROOTDIR/scripts/iam/run_aup_phantomjs.sh \
  $X509_USER_CERT $X509_USER_KEY $IAM_FQDN $CLIENT_PATH
done
