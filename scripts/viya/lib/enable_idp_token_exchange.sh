#!/usr/bin/env bash

set -euo pipefail

die() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

if [[ "${1:-}" == --help || "${1:-}" == -h ]]; then
  printf 'Enable Keycloak identity-provider token exchange for EXCHANGE_CLIENT_ID.\n'
  printf 'Required environment: RAM_URL, RAM_KC_PASSWORD.\n'
  exit 0
fi
(( $# == 0 )) || die "Unknown option: $1"
for name in RAM_URL RAM_KC_PASSWORD; do
  [[ -n "${!name:-}" ]] || die "$name environment variable is not set"
done
for executable in curl jq; do
  command -v "$executable" >/dev/null 2>&1 || die "$executable is required."
done

RAM_URL=${RAM_URL%/}
RAM_KC_USER=${RAM_KC_USER:-kcAdmin}
RAM_KC_REALM=${RAM_KC_REALM:-sas-iot}
IDP_ALIAS=${IDP_ALIAS:-viya-oidc}
EXCHANGE_CLIENT_ID=${EXCHANGE_CLIENT_ID:-sas-ram-app}
KEYCLOAK_API_BASE=${KEYCLOAK_API_BASE:-$RAM_URL/SASRetrievalAgentManager/auth}
realm_base="${KEYCLOAK_API_BASE%/}/admin/realms/$RAM_KC_REALM"
tls_args=()
case "${SSL_VERIFY:-false}" in
  0|[Ff][Aa][Ll][Ss][Ee]|[Nn][Oo]|[Oo][Ff][Ff]) tls_args=(--insecure) ;;
esac
umask 077
temporary_directory=$(mktemp -d)
trap 'rm -rf "$temporary_directory"' EXIT
response_file="$temporary_directory/response.json"
body_file="$temporary_directory/body.json"

request() {
  local method=$1 url=$2 http_status
  shift 2
  http_status=$(curl --silent --show-error "${tls_args[@]}" --max-time 30 \
    --request "$method" --output "$response_file" --write-out '%{http_code}' \
    "$url" "$@") || die "$method request failed before an HTTP response."
  printf '%s -> HTTP %s\n' "$method" "$http_status" >&2
  [[ "$http_status" =~ ^2[0-9][0-9]$ ]] || die "$method request failed (HTTP $http_status)."
}

request POST "$RAM_URL/SASRetrievalAgentManager/auth/realms/master/protocol/openid-connect/token" \
  --data-urlencode 'grant_type=password' --data-urlencode 'client_id=admin-cli' \
  --data-urlencode "username=$RAM_KC_USER" --data-urlencode "password=$RAM_KC_PASSWORD"
kc_token=$(jq -er '.access_token // empty' "$response_file") \
  || die 'Keycloak admin token response did not contain access_token'
headers=(-H "Authorization: Bearer $kc_token" -H 'Content-Type: application/json')

find_client_uuid() {
  local client_id=$1
  request GET "$realm_base/clients" "${headers[@]}" --get --data-urlencode "clientId=$client_id"
  jq -er --arg client_id "$client_id" \
    '[.[] | select(.clientId == $client_id)] | if length == 1 then .[0].id else empty end' \
    "$response_file" || die "Client '$client_id' not found or not unique."
}

realm_mgmt_uuid=$(find_client_uuid realm-management)
exchange_client_uuid=$(find_client_uuid "$EXCHANGE_CLIENT_ID")
printf '%s' '{"enabled":true}' >"$body_file"
request PUT "$realm_base/identity-provider/instances/$IDP_ALIAS/management/permissions" \
  "${headers[@]}" --data-binary "@$body_file"
permission_id=$(jq -er '.scopePermissions["token-exchange"] // empty' "$response_file") \
  || die "IDP has no token-exchange permission. Confirm admin-fine-grained-authz:v1 and token-exchange server features."

policy_name="$EXCHANGE_CLIENT_ID-token-exchange-policy"
policy_base="$realm_base/clients/$realm_mgmt_uuid/authz/resource-server/policy"
request GET "$policy_base" "${headers[@]}" --get \
  --data-urlencode "name=$policy_name" --data-urlencode 'exactName=true'
policy_id=$(jq -r '.[0].id // empty' "$response_file")
jq -n --arg name "$policy_name" --arg client "$exchange_client_uuid" \
  --arg id "$policy_id" \
  '{name:$name,logic:"POSITIVE",clients:[$client]} + (if $id == "" then {} else {id:$id} end)' \
  >"$body_file"
if [[ -n "$policy_id" ]]; then
  request PUT "$policy_base/client/$policy_id" "${headers[@]}" --data-binary "@$body_file"
else
  request POST "$policy_base/client" "${headers[@]}" --data-binary "@$body_file"
  policy_id=$(jq -er '.id // empty' "$response_file") || die 'Keycloak returned no client policy ID.'
fi

permission_base="$realm_base/clients/$realm_mgmt_uuid/authz/resource-server/permission"
request GET "$permission_base/$permission_id" "${headers[@]}"
jq --arg policy_id "$policy_id" \
  '.policies = [$policy_id] | .decisionStrategy = "UNANIMOUS"' "$response_file" >"$body_file"
request PUT "$permission_base/scope/$permission_id" "${headers[@]}" --data-binary "@$body_file"
printf "Client '%s' is now authorized to token-exchange using IDP '%s' as subject_issuer.\n" \
  "$EXCHANGE_CLIENT_ID" "$IDP_ALIAS"