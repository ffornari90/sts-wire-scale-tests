#!/bin/bash
if ! [[ $# -eq 3 ]] ; then
    echo 'ERROR: You must provide an OIDC admin client name, an issuer URL and a group ID.'
    exit 1
fi

OIDC_ADMIN_CLIENT=$1
IAM_URL=$2
group_id=$3

declare -a usernames
declare -a ids

TOKEN=$(oidc-token $OIDC_ADMIN_CLIENT)
IAM_USERS_ENDPOINT=$IAM_URL/scim/Users
IAM_ACCOUNT_ENDPOINT=$IAM_URL/iam/account

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
    ids+=("${ids_page[$index_j]}")
    usernames+=("${usernames_page[$index_j]}")
  done
done

for user_id in "${ids[@]}"
do
  curl -s -H "Authorization: Bearer $TOKEN" -X POST ${IAM_ACCOUNT_ENDPOINT}/$user_id/groups/$group_id
done
