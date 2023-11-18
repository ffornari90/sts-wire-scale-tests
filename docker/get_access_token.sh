#!/bin/bash
CLIENT_PATH=$HOME/client/client.json
CLIENT_ID=$(cat $CLIENT_PATH | jq -r '.client_id')
CLIENT_SECRET=$(cat $CLIENT_PATH | jq -r '.client_secret')
IAM_FQDN=$(echo $IAM_URL | awk -F 'https://' '{print $2}')
IAM_CLIENT_SCOPES=${IAM_CLIENT_SCOPES:-"openid profile"}
IAM_TOKEN_ENDPOINT="https://${IAM_FQDN}/token"
IAM_AUTHORIZATION_ENDPOINT="https://${IAM_FQDN}/authorize"
IAM_DASHBOARD_ENDPOINT="https://${IAM_FQDN}/dashboard"
REDIRECT_URI=$(cat $CLIENT_PATH | jq -r '.redirect_uris[0]')
X509_USER_CERT="$HOME/public.crt"
X509_USER_KEY="$HOME/private.key"

while true; do
    AUTHORIZATION_CODE=$(./run_phantomjs.sh \
    $X509_USER_CERT $X509_USER_KEY $IAM_FQDN \
    | awk -F'?' '{print $2}' | tr -d '\r')

    response=$(mktemp)

    curl -s -L \
        --user ${CLIENT_ID}:${CLIENT_SECRET} \
        -d grant_type=authorization_code \
        -d "scope=${IAM_CLIENT_SCOPES}" \
        -d "${AUTHORIZATION_CODE}" \
        -d "redirect_uri=${REDIRECT_URI}" \
        -d "audience=${AUDIENCE}" \
        ${IAM_TOKEN_ENDPOINT} 2>&1 > ${response}

    if [ $? -eq 0 ]; then
        error=$(jq -r .error ${response})
        error_description=$(jq -r .error_description ${response})

        if [ "${error}" = "null" ] || [ -z "${error}" ]; then
            access_token=$(jq -r .access_token ${response})
            refresh_token=$(jq -r .refresh_token ${response})
            scope=$(jq -r .scope ${response})
            expires_in=$(jq -r .expires_in ${response})

            export ACCESS_TOKEN=${access_token}
            export REFRESH_TOKEN=${refresh_token}
            export IAM_CLIENT_ID=${CLIENT_ID}
            export IAM_CLIENT_SECRET=${CLIENT_SECRET}
            break
        fi
    fi
done
