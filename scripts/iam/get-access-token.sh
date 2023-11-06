#!/bin/bash
ROOTDIR=$(git rev-parse --show-toplevel)
if ! [[ $# -eq 3 ]] ; then
    echo 'ERROR: You must provide a client index, an issuer URL and an audience value.'
    exit 1
fi
OIDC_CLIENT_INDEX=$1
IAM_URL=$2
AUDIENCE=$3
CLIENT_ID=$(cat $ROOTDIR/scripts/sts-wire/conf/client$OIDC_CLIENT_INDEX/client.json | jq -r '.client_id')
CLIENT_SECRET=$(cat $ROOTDIR/scripts/sts-wire/conf/client$OIDC_CLIENT_INDEX/client.json | jq -r '.client_secret')
IAM_FQDN=$(echo $IAM_URL | awk -F 'https://' '{print $2}')
IAM_CLIENT_SCOPES=${IAM_CLIENT_SCOPES:-"openid profile"}
IAM_TOKEN_ENDPOINT="https://${IAM_FQDN}/token"
IAM_AUTHORIZATION_ENDPOINT="https://${IAM_FQDN}/authorize"
IAM_DASHBOARD_ENDPOINT="https://${IAM_FQDN}/dashboard"
REDIRECT_URI=$(cat $ROOTDIR/scripts/sts-wire/conf/client$OIDC_CLIENT_INDEX/client.json | jq -r '.redirect_uris[0]')
X509_USER_CERT="${ROOTDIR}/scripts/sts-wire/conf/certs/client$1/public.crt"
X509_USER_KEY="${ROOTDIR}/scripts/sts-wire/conf/certs/client$1/private.key"
AUTHORIZATION_CODE=$($ROOTDIR/scripts/iam/run_phantomjs.sh \
$X509_USER_CERT $X509_USER_KEY $IAM_FQDN | awk -F'?' '{print $2}' | tr -d '\r')

response=$(mktemp)

curl -s -L \
    --user ${CLIENT_ID}:${CLIENT_SECRET} \
    -d grant_type=authorization_code \
    -d "scope=${IAM_CLIENT_SCOPES}" \
    -d "${AUTHORIZATION_CODE}" \
    -d "redirect_uri=${REDIRECT_URI}" \
    -d "audience=${AUDIENCE}" \
    ${IAM_TOKEN_ENDPOINT} 2>&1 > ${response}

if [ $? -ne 0 ]; then
  echo "Error contacting IAM"
  cat ${response}
  exit 1
fi

error=$(jq -r .error ${response})
error_description=$(jq -r .error_description ${response})

if [ "${error}" != "null" ]; then
  echo "IAM returned the following error:"
  echo
  echo ${error} " " ${error_description}
  echo
fi

access_token=$(jq -r .access_token ${response})
refresh_token=$(jq -r .refresh_token ${response})
scope=$(jq -r .scope ${response})
expires_in=$(jq -r .expires_in ${response})

echo ${access_token}
