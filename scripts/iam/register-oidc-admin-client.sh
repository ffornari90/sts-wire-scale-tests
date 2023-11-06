#!/bin/bash
if ! [[ $# -eq 2 ]] ; then
    echo 'ERROR: You must provide an OIDC admin client name and an issuer URL.'
    exit 1
fi
OIDC_ADMIN_CLIENT=$1
IAM_URL=$2
oidc-gen --scope-all --confirm-default --iss=$IAM_URL $OIDC_ADMIN_CLIENT --flow=device
