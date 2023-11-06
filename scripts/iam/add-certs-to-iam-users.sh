#!/bin/bash
ROOTDIR=$(git rev-parse --show-toplevel)
if ! [[ $# -eq 2 ]] ; then
    echo 'ERROR: You must provide an OIDC admin client name and an issuer URL.'
    exit 1
fi

OIDC_ADMIN_CLIENT=$1
IAM_URL=$2

declare -a usernames
declare -a ids

TOKEN=$(oidc-token $OIDC_ADMIN_CLIENT)
IAM_USERS_ENDPOINT=$IAM_URL/scim/Users

function number_of_users() {
  curl -s -H "Authorization: Bearer $TOKEN" $IAM_USERS_ENDPOINT?count=0 | jq -r '.totalResults'
}

NUSERS=$(number_of_users)
HUNDREDS=$((NUSERS / 100 + 1))

for ((index=0; index != HUNDREDS; ++index)); do
  start_index=$((index * 100 + 1))
  usernames_page=(`curl -s -H "Authorization: Bearer $TOKEN" $IAM_USERS_ENDPOINT?startIndex=$start_index | jq -r '.Resources[] | "\(.userName) \(.id)"' | grep client | awk '{print $1}'`)
  ids_page=(`curl -s -H "Authorization: Bearer $TOKEN" $IAM_USERS_ENDPOINT?startIndex=$start_index | jq -r '.Resources[] | "\(.userName) \(.id)"' | grep client | awk '{print $2}'`)
  for index_j in "${!ids_page[@]}"; do
    usernames+=("${usernames_page[$index_j]}")
    ids+=("${ids_page[$index_j]}")
  done
done

for index_k in "${!ids[@]}"
do
  cert=$(awk '{printf "%s\\n", $0}' "${ROOTDIR}/scripts/sts-wire/conf/certs/${usernames[$index_k]}/public.crt")
  cat > payload.json <<EOF
{
  "schemas": [
    "urn:ietf:params:scim:api:messages:2.0:PatchOp"
  ],
  "operations": [
    {
      "op": "add",
      "value": {
        "urn:indigo-dc:scim:schemas:IndigoUser": {
          "certificates": [
            {
              "pemEncodedCertificate": "${cert}",
              "label": "${usernames[$index_k]}"
            }
          ]
        }
      }
    }
  ]
}
EOF
  curl -L -s -H "Authorization: Bearer $TOKEN" -H "Content-type: application/scim+json" -X PATCH -d @payload.json -H "Accept: application/json, text/plain, */*" "${IAM_USERS_ENDPOINT}/${ids[$index_k]}"
done
