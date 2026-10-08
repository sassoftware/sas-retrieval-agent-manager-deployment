#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

die() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

if [[ "${1:-}" == --help || "${1:-}" == -h ]]; then
  printf 'Connect SAS Viya identity and its MCP tools server to an existing RAM cluster.\n'
  exit 0
fi
(( $# == 0 )) || die "Unknown option: $1"

RAM_KUBE_CONTEXT=${RAM_KUBE_CONTEXT:-${KUBE_CONTEXT:-}}
VIYA_KUBE_CONTEXT=${VIYA_KUBE_CONTEXT:-${KUBE_CONTEXT:-}}
RAM_KUBECONFIG=${RAM_KUBECONFIG:-${KUBECONFIG:-/root/.kube/config}}
VIYA_KUBECONFIG=${VIYA_KUBECONFIG:-${KUBECONFIG:-/root/.kube/config}}

for name in RAM_KUBE_CONTEXT VIYA_KUBE_CONTEXT VIYA_URL VIYA_USER VIYA_PASSWORD VIYA_CLIENT_SECRET \
  RAM_URL RAM_KC_PASSWORD MCP_IMAGE; do
  [[ -n "${!name:-}" ]] || die "Required environment variable unset: $name"
done

VIYA_URL=${VIYA_URL%/}
RAM_URL=${RAM_URL%/}
ISSUER_URI=${ISSUER_URI:-$VIYA_URL/SASLogon}
ISSUER_URI=${ISSUER_URI%/}
RAM_NAMESPACE=${RAM_NAMESPACE:-retagentmgr}
VIYA_NAMESPACE=${VIYA_NAMESPACE:-viya}
RAM_RELEASE=${RAM_RELEASE:-retrieval-agent-manager}
IDP_ALIAS=${IDP_ALIAS:-viya-oidc}
MCP_CLIENT_ID=${MCP_CLIENT_ID:-ram-app}
MCP_CLIENT_SECRET=${MCP_CLIENT_SECRET:-ram-secret}

for name in VIYA_URL RAM_URL; do
  [[ "${!name}" =~ ^https://[^/?#[:space:]]+$ ]] \
    || die "$name must be an HTTPS URL with only a host."
done
[[ "$MCP_CLIENT_ID" =~ ^[A-Za-z0-9._-]+$ ]] \
  || die 'MCP_CLIENT_ID contains unsupported characters.'
[[ "$MCP_CLIENT_SECRET" != *$'\n'* && "$MCP_CLIENT_SECRET" != *$'\r'* ]] \
  || die 'MCP_CLIENT_SECRET contains a newline.'
[[ "$ISSUER_URI" =~ ^https://[^/?#[:space:]]+/SASLogon$ ]] \
  || die 'ISSUER_URI must end with /SASLogon on an HTTPS host.'
[[ "$MCP_IMAGE" =~ ^[^[:space:]]+(:[A-Za-z0-9_.-]+|@sha256:[0-9a-f]{64})$ ]] \
  || die 'MCP_IMAGE must have a tag or sha256 digest.'
[[ "$IDP_ALIAS" =~ ^[A-Za-z0-9._-]+$ ]] \
  || die 'IDP_ALIAS contains unsupported characters.'
for name in RAM_NAMESPACE VIYA_NAMESPACE RAM_RELEASE; do
  [[ "${!name}" =~ ^[a-z0-9]([-a-z0-9]*[a-z0-9])?$ ]] \
    || die "$name is not a valid Kubernetes name."
done
for name in RAM_KUBE_CONTEXT VIYA_KUBE_CONTEXT; do
  [[ "${!name}" != *$'\n'* && "${!name}" != *$'\r'* ]] \
    || die "$name contains a newline."
done

export VIYA_URL RAM_URL ISSUER_URI RAM_NAMESPACE RAM_RELEASE IDP_ALIAS \
  RAM_KUBE_CONTEXT VIYA_KUBE_CONTEXT RAM_KUBECONFIG VIYA_KUBECONFIG \
  MCP_IMAGE VIYA_NAMESPACE MCP_CLIENT_ID MCP_CLIENT_SECRET
RAM_KUBECTL=(kubectl --kubeconfig "$RAM_KUBECONFIG" --context "$RAM_KUBE_CONTEXT")
VIYA_KUBECTL=(kubectl --kubeconfig "$VIYA_KUBECONFIG" --context "$VIYA_KUBE_CONTEXT")

for executable in base64 curl jq kubectl python3; do
  command -v "$executable" >/dev/null 2>&1 || die "$executable is required."
done

printf 'RAM Kubernetes context: %s\nViya Kubernetes context: %s\nRAM namespace: %s\nViya namespace: %s\n' \
  "$RAM_KUBE_CONTEXT" "$VIYA_KUBE_CONTEXT" "$RAM_NAMESPACE" "$VIYA_NAMESPACE"
"${RAM_KUBECTL[@]}" --namespace "$RAM_NAMESPACE" get deployment \
  "${RAM_RELEASE}-api" "${RAM_RELEASE}-app" >/dev/null \
  || die 'The RAM deployments are not available in the selected cluster.'
"${RAM_KUBECTL[@]}" --namespace "$RAM_NAMESPACE" get configmap \
  "${RAM_RELEASE}-oauth2-proxy" >/dev/null \
  || die 'The RAM oauth2-proxy ConfigMap is not available.'
"${RAM_KUBECTL[@]}" --namespace "$RAM_NAMESPACE" get secret \
  "${RAM_RELEASE}-keycloak-client-secret" "${RAM_RELEASE}-keycloak-appadmin-secret" \
  >/dev/null || die 'The RAM Keycloak Secrets are not available.'
client_secret=$("${RAM_KUBECTL[@]}" --namespace "$RAM_NAMESPACE" get secret \
  "${RAM_RELEASE}-keycloak-client-secret" -o json) \
  || die 'Could not read the RAM Keycloak client Secret.'
cluster_realm=$(printf '%s' "$client_secret" | jq -er '.data.realm // empty' \
  | base64 --decode) || die 'The RAM Keycloak client Secret has no realm.'
cluster_client_id=$(printf '%s' "$client_secret" \
  | jq -er '.data["sv-client-id"] // empty' | base64 --decode) \
  || die 'The RAM Keycloak client Secret has no client ID.'
unset client_secret
[[ -n "$cluster_realm" && -n "$cluster_client_id" ]] \
  || die 'The RAM Keycloak client Secret has empty identity values.'
[[ -z "${RAM_KC_REALM:-}" || "$RAM_KC_REALM" == "$cluster_realm" ]] \
  || die 'RAM_KC_REALM does not match the selected RAM cluster.'
[[ -z "${RAM_KC_CLIENT_ID:-}" || "$RAM_KC_CLIENT_ID" == "$cluster_client_id" ]] \
  || die 'RAM_KC_CLIENT_ID does not match the selected RAM cluster.'
export RAM_KC_REALM=$cluster_realm RAM_KC_CLIENT_ID=$cluster_client_id
export EXCHANGE_CLIENT_ID=$RAM_KC_CLIENT_ID
"${VIYA_KUBECTL[@]}" --namespace "$VIYA_NAMESPACE" get deployment sas-logon-app \
  >/dev/null || die 'SAS Logon is not available in the selected cluster.'

umask 077
temporary_directory=$(mktemp -d)
trap 'rm -rf "$temporary_directory"' EXIT

printf 'Provisioning Viya home directories...\n'
KUBECONFIG="$VIYA_KUBECONFIG" \
KUBE_CONTEXT="$VIYA_KUBE_CONTEXT" \
PROVISION_NAMESPACE="$VIYA_NAMESPACE" \
SASBOOT_PASSWORD="$VIYA_PASSWORD" \
VIYA_USER="$VIYA_USER" \
bash "$SCRIPT_DIR/provision-viya-home-directories.sh"

viya_token_issuer() {
  local token payload
  token=$(curl -ksSf -X POST "$VIYA_URL/SASLogon/oauth/token" -u 'sas.cli:' \
    --data-urlencode 'grant_type=password' \
    --data-urlencode "username=$VIYA_USER" \
    --data-urlencode "password=$VIYA_PASSWORD" | jq -er '.access_token // empty') \
    || die 'Could not get a Viya access token.'
  payload=${token#*.}
  payload=${payload%%.*}
  [[ -n "$payload" && "$payload" != "$token" ]] \
    || die 'The Viya access token is not a JSON Web Token.'
  payload=$(printf '%s' "$payload" | tr '_-' '/+')
  while (( ${#payload} % 4 )); do
    payload+='='
  done
  printf '%s' "$payload" | base64 --decode 2>/dev/null | jq -er '.iss // empty' \
    || die 'Could not read the Viya access token issuer.'
}

set_viya_issuer() {
  "${VIYA_KUBECTL[@]}" --namespace "$VIYA_NAMESPACE" exec -i \
    deployment/sas-logon-app -c sas-logon-app -- sh -s -- "$ISSUER_URI" <<'REMOTE_SCRIPT'
set -eu
issuer_uri=$1
password=$(/opt/sas/viya/home/bin/sas-bootstrap-config kv read --global 'sas.logon/initial/password')
[ -n "$password" ] || { printf 'SAS boot password is not available.\n' >&2; exit 1; }
temporary_directory=$(mktemp -d)
trap 'rm -rf "$temporary_directory"; unset password token' EXIT
token=$(curl -ksSf -X POST https://localhost:8080/SASLogon/oauth/token \
  -u 'sas.cli:' --data-urlencode 'grant_type=password' \
  --data-urlencode 'username=sasboot' --data-urlencode "password=$password" \
  | python3 -c 'import json,sys; print(json.load(sys.stdin)["access_token"])')
unset password
curl -ksSf 'https://sas-configuration/configuration/definitions?limit=1000' \
  -H "Authorization: Bearer $token" -H 'Accept: application/json' \
  >"$temporary_directory/definitions.json"
content_type=$(python3 - "$temporary_directory/definitions.json" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as source:
    data = json.load(source)
items = [item for item in data["items"] if item["name"] == "sas.logon.jwt"]
item = max(items, key=lambda value: value["definitionVersion"])
print(next(link["itemType"] for link in item["links"]
           if link["rel"] == "createConfigurations"))
PY
)
curl -ksSf 'https://sas-configuration/configuration/configurations?definitionName=sas.logon.jwt' \
  -H "Authorization: Bearer $token" -H 'Accept: application/json' \
  >"$temporary_directory/configurations.json"
action=$(python3 - "$temporary_directory/configurations.json" "$issuer_uri" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as source:
    items = json.load(source).get("items", [])
if len(items) > 1:
  raise SystemExit(
    f"Expected at most one sas.logon.jwt configuration; found {len(items)}."
  )
if not items:
    print("CREATE")
elif any(item.get("configuration", {}).get("issuer.uri") == sys.argv[2]
         for item in items):
    print("MATCH")
else:
    link = next((link.get("href") for link in items[0].get("links", [])
                 if link.get("rel") == "update"), None)
    if not link:
        raise SystemExit("SAS Logon configuration has no update link.")
    print("UPDATE " + link)
PY
)
if [ "$action" != MATCH ]; then
  case "$action" in
    CREATE) method=POST; target='https://sas-configuration/configuration/configurations' ;;
    'UPDATE '*)
      method=PUT
      target=${action#UPDATE }
      case "$target" in
        https://*) ;;
        /*) target="https://sas-configuration$target" ;;
        *) printf 'SAS Logon configuration has an invalid update link.\n' >&2; exit 1 ;;
      esac
      ;;
    *) printf 'Could not select a SAS Logon configuration update.\n' >&2; exit 1 ;;
  esac
  payload=$(python3 -c 'import json,sys; print(json.dumps({"issuer.uri":sys.argv[1]}))' "$issuer_uri")
  status=$(curl -ksS -X "$method" "$target" \
    -H "Authorization: Bearer $token" -H "Content-Type: $content_type" \
    -H 'Accept: application/json' --data "$payload" -o /dev/null -w '%{http_code}')
  case "$status" in
    200|201|204) ;;
    *) printf 'SAS Logon issuer update returned HTTP %s.\n' "$status" >&2; exit 1 ;;
  esac
fi
REMOTE_SCRIPT
  "${VIYA_KUBECTL[@]}" --namespace "$VIYA_NAMESPACE" rollout restart deployment/sas-logon-app
  "${VIYA_KUBECTL[@]}" --namespace "$VIYA_NAMESPACE" rollout status \
    deployment/sas-logon-app --timeout=180s
}

configure_mcp_oauth_client() {
  local access_token http_status group_file client_file secret_file response_file
  access_token=$(curl -ksSf -X POST "$VIYA_URL/SASLogon/oauth/token" \
    -u 'sas.cli:' --data-urlencode 'grant_type=password' \
    --data-urlencode "username=$VIYA_USER" \
    --data-urlencode "password=$VIYA_PASSWORD" \
    | jq -er '.access_token // empty') \
    || die 'Could not get a Viya access token for the MCP OAuth client.'

  group_file="$temporary_directory/mcp-client-group.json"
  client_file="$temporary_directory/mcp-client.json"
  secret_file="$temporary_directory/mcp-client-secret"
  response_file="$temporary_directory/mcp-client-response.json"
  printf '%s' "$MCP_CLIENT_SECRET" >"$secret_file"
  jq -n --arg id "$MCP_CLIENT_ID" \
    --arg name "RAM Application Group ($MCP_CLIENT_ID)" \
    '{id: $id, name: $name}' >"$group_file"
  http_status=$(curl -ksS -o "$response_file" -w '%{http_code}' \
    -X POST "$VIYA_URL/identities/groups" \
    -H "Authorization: Bearer $access_token" \
    -H 'Content-Type: application/json' --data-binary "@$group_file") \
    || die 'Could not create the Viya MCP OAuth group.'
  case "$http_status" in
    200|201|409) ;;
    *) die "Viya MCP OAuth group creation returned HTTP $http_status." ;;
  esac

  jq -n --arg id "$MCP_CLIENT_ID" \
    --rawfile secret "$secret_file" \
    '{client_id: $id, client_secret: $secret, authorities: [$id],
      authorized_grant_types: ["client_credentials"], uid: "2001", gid: "2001"}' \
    >"$client_file"
  http_status=$(curl -ksS -o "$response_file" -w '%{http_code}' \
    -X POST "$VIYA_URL/SASLogon/oauth/clients" \
    -H "Authorization: Bearer $access_token" \
    -H 'Content-Type: application/json' --data-binary "@$client_file") \
    || die 'Could not create the Viya MCP OAuth client.'
  case "$http_status" in
    201)
      printf 'Created the Viya MCP OAuth client.\n'
      ;;
    409)
      http_status=$(curl -ksS -o "$response_file" -w '%{http_code}' \
        -X PUT "$VIYA_URL/SASLogon/oauth/clients/$MCP_CLIENT_ID" \
        -H "Authorization: Bearer $access_token" \
        -H 'Content-Type: application/json' --data-binary "@$client_file") \
        || die 'Could not update the Viya MCP OAuth client.'
      case "$http_status" in
        200|201|204) ;;
        *) die "Viya MCP OAuth client update returned HTTP $http_status." ;;
      esac
      jq -n --arg id "$MCP_CLIENT_ID" --rawfile secret "$secret_file" \
        '{clientId: $id, secret: $secret}' >"$temporary_directory/mcp-client-secret.json"
      http_status=$(curl -ksS -o "$response_file" -w '%{http_code}' \
        -X PUT "$VIYA_URL/SASLogon/oauth/clients/$MCP_CLIENT_ID/secret" \
        -H "Authorization: Bearer $access_token" \
        -H 'Content-Type: application/json' \
        --data-binary "@$temporary_directory/mcp-client-secret.json") \
        || die 'Could not update the Viya MCP OAuth client secret.'
      case "$http_status" in
        200|201|204) ;;
        *) die "Viya MCP OAuth client secret update returned HTTP $http_status." ;;
      esac
      printf 'Updated the existing Viya MCP OAuth client.\n'
      ;;
    *) die "Viya MCP OAuth client creation returned HTTP $http_status." ;;
  esac
}

printf 'Checking the SAS Logon issuer...\n'
if [[ "$(viya_token_issuer)" != "$ISSUER_URI/oauth/token" ]]; then
  set_viya_issuer
  [[ "$(viya_token_issuer)" == "$ISSUER_URI/oauth/token" ]] \
    || die 'The SAS Logon issuer did not match after restart.'
fi
discovery_issuer=$(curl -ksSf "$VIYA_URL/SASLogon/.well-known/openid-configuration" \
  | jq -er '.issuer // empty') || die 'Could not read the Viya OpenID discovery issuer.'
[[ "$discovery_issuer" == "$ISSUER_URI/oauth/token" ]] \
  || die 'The Viya OpenID discovery issuer does not match the token issuer.'

printf 'Linking Viya identity to RAM Keycloak...\n'
bash "$SCRIPT_DIR/link_viya_identity.sh"
kc_token=$(curl -ksSf -X POST \
  "$RAM_URL/SASRetrievalAgentManager/auth/realms/master/protocol/openid-connect/token" \
  --data-urlencode 'grant_type=password' --data-urlencode 'client_id=admin-cli' \
  --data-urlencode "username=${RAM_KC_USER:-kcAdmin}" \
  --data-urlencode "password=$RAM_KC_PASSWORD" | jq -er '.access_token // empty') \
  || die 'Could not verify the Keycloak identity provider.'
idp_status=$(curl -ksS -o "$temporary_directory/idp.json" -w '%{http_code}' \
  -H "Authorization: Bearer $kc_token" \
  "$RAM_URL/SASRetrievalAgentManager/auth/admin/realms/$RAM_KC_REALM/identity-provider/instances/$IDP_ALIAS") \
  || die 'Could not read the Keycloak identity provider.'
unset kc_token
[[ "$idp_status" == 200 ]] || die "Keycloak identity provider lookup returned HTTP $idp_status."
jq -e --arg issuer "$ISSUER_URI/oauth/token" \
  --arg client_id "${VIYA_CLIENT_ID:-ram-client}" '
  .enabled == true and .storeToken == true and .config.issuer == $issuer
  and .config.clientId == $client_id
' "$temporary_directory/idp.json" >/dev/null \
  || die 'The Keycloak identity provider does not match the Viya issuer and client.'
printf 'Granting the RAM client token-exchange access...\n'
bash "$SCRIPT_DIR/enable_idp_token_exchange.sh"

config_name="${RAM_RELEASE}-oauth2-proxy"
config_file="$temporary_directory/oauth2-proxy.cfg"
"${RAM_KUBECTL[@]}" --namespace "$RAM_NAMESPACE" get configmap "$config_name" \
  -o jsonpath='{.data.oauth2-proxy\.cfg}' >"$config_file"
[[ -s "$config_file" ]] || die 'The oauth2-proxy configuration is empty.'
cp "$config_file" "$temporary_directory/original.cfg"

CONFIG_FILE="$config_file" IDP_ALIAS="$IDP_ALIAS" ISSUER_URI="$ISSUER_URI" \
  python3 <<'PY'
import os
import re
from pathlib import Path
from urllib.parse import parse_qsl, urlencode, urlsplit, urlunsplit

config_file = Path(os.environ["CONFIG_FILE"])
content = config_file.read_text()
login = re.compile(r'(?m)^(\s*login_url\s*=\s*")([^"]+)("\s*)$')
matches = list(login.finditer(content))
if len(matches) != 1:
    raise SystemExit("Expected exactly one oauth2-proxy login_url setting.")
match = matches[0]
parts = urlsplit(match.group(2))
if not parts.path.endswith("/protocol/openid-connect/auth"):
    raise SystemExit("oauth2-proxy login_url does not target Keycloak.")
query = [(key, value) for key, value in parse_qsl(parts.query, keep_blank_values=True)
         if key != "kc_idp_hint"]
query.append(("kc_idp_hint", os.environ["IDP_ALIAS"]))
url = urlunsplit((parts.scheme, parts.netloc, parts.path, urlencode(query), parts.fragment))
content = content[:match.start()] + match.group(1) + url + match.group(3) + content[match.end():]

bearer = re.findall(
  r'(?m)^\s*skip_jwt_bearer_tokens\s*=\s*true\s*$',
  content,
)
if len(bearer) != 1:
    raise SystemExit("oauth2-proxy must have skip_jwt_bearer_tokens = true.")

issuer_value = os.environ["ISSUER_URI"] + "/oauth/token=openid"
issuer_key = issuer_value.rsplit("=", 1)[0]
issuer_setting = re.compile(
  r'(?m)^([ \t]*extra_jwt_issuers[ \t]*=[ \t]*")([^\"]*)("[ \t]*)$'
)
existing = list(issuer_setting.finditer(content))
if len(existing) > 1:
  raise SystemExit("oauth2-proxy has multiple extra_jwt_issuers settings.")

configured_issuers = []
if existing:
  configured_issuers = [
    value.strip()
    for value in existing[0].group(2).split(",")
    if value.strip()
  ]

configured_issuers = [
  value
  for value in configured_issuers
  if value.split("=", 1)[0] != issuer_key
]
configured_issuers.append(issuer_value)
updated_value = ",".join(configured_issuers)

if existing:
  match = existing[0]
  replacement = match.group(1) + updated_value + match.group(3)
  content = content[:match.start()] + replacement + content[match.end():]
else:
  content = content.rstrip("\n") + "\nextra_jwt_issuers = \"" + updated_value + "\"\n"
config_file.write_text(content)
PY

if ! cmp -s "$config_file" "$temporary_directory/original.cfg"; then
  "${RAM_KUBECTL[@]}" --namespace "$RAM_NAMESPACE" create configmap "$config_name" \
    --from-file="oauth2-proxy.cfg=$config_file" --dry-run=client -o yaml \
    | "${RAM_KUBECTL[@]}" --namespace "$RAM_NAMESPACE" apply -f -
  for deployment in "${RAM_RELEASE}-api" "${RAM_RELEASE}-app"; do
    "${RAM_KUBECTL[@]}" --namespace "$RAM_NAMESPACE" rollout restart "deployment/$deployment"
    "${RAM_KUBECTL[@]}" --namespace "$RAM_NAMESPACE" rollout status \
      "deployment/$deployment" --timeout=180s
  done
fi

printf 'Registering RAM in the Viya application registry...\n'
bash "$SCRIPT_DIR/register-ram-with-viya.sh" \
  --viya-url "$VIYA_URL" --username "$VIYA_USER"

printf 'Configuring the Viya client for OAuth-authenticated MCP...\n'
configure_mcp_oauth_client

printf 'Registering the OAuth and user-authenticated SAS MCP tools servers...\n'
bash "$SCRIPT_DIR/register-viya-mcp.sh"
printf 'Configured Viya SSO, registered RAM in the Viya application registry, and requested both SAS MCP tools server deployments in RAM.\n'