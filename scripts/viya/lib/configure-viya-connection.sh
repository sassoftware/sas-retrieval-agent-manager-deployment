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

for name in KUBE_CONTEXT VIYA_URL VIYA_USER VIYA_PASSWORD VIYA_CLIENT_SECRET \
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

for name in VIYA_URL RAM_URL; do
  [[ "${!name}" =~ ^https://[^/?#[:space:]]+$ ]] \
    || die "$name must be an HTTPS URL with only a host."
done
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
[[ "$KUBE_CONTEXT" != *$'\n'* && "$KUBE_CONTEXT" != *$'\r'* ]] \
  || die 'KUBE_CONTEXT contains a newline.'

export VIYA_URL RAM_URL ISSUER_URI RAM_NAMESPACE RAM_RELEASE IDP_ALIAS \
  KUBE_CONTEXT MCP_IMAGE VIYA_NAMESPACE
KUBECTL=(kubectl --context "$KUBE_CONTEXT")

for executable in base64 curl jq kubectl python3; do
  command -v "$executable" >/dev/null 2>&1 || die "$executable is required."
done

printf 'Kubernetes context: %s\nRAM namespace: %s\nViya namespace: %s\n' \
  "$KUBE_CONTEXT" "$RAM_NAMESPACE" "$VIYA_NAMESPACE"
"${KUBECTL[@]}" --namespace "$RAM_NAMESPACE" get deployment \
  "${RAM_RELEASE}-api" "${RAM_RELEASE}-app" >/dev/null \
  || die 'The RAM deployments are not available in the selected cluster.'
"${KUBECTL[@]}" --namespace "$RAM_NAMESPACE" get configmap \
  "${RAM_RELEASE}-oauth2-proxy" >/dev/null \
  || die 'The RAM oauth2-proxy ConfigMap is not available.'
"${KUBECTL[@]}" --namespace "$RAM_NAMESPACE" get secret \
  "${RAM_RELEASE}-keycloak-client-secret" "${RAM_RELEASE}-keycloak-appadmin-secret" \
  >/dev/null || die 'The RAM Keycloak Secrets are not available.'
client_secret=$("${KUBECTL[@]}" --namespace "$RAM_NAMESPACE" get secret \
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
"${KUBECTL[@]}" --namespace "$VIYA_NAMESPACE" get deployment sas-logon-app \
  >/dev/null || die 'SAS Logon is not available in the selected cluster.'

umask 077
temporary_directory=$(mktemp -d)
trap 'rm -rf "$temporary_directory"' EXIT

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
  "${KUBECTL[@]}" --namespace "$VIYA_NAMESPACE" exec -i \
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
  "${KUBECTL[@]}" --namespace "$VIYA_NAMESPACE" rollout restart deployment/sas-logon-app
  "${KUBECTL[@]}" --namespace "$VIYA_NAMESPACE" rollout status \
    deployment/sas-logon-app --timeout=180s
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
"${KUBECTL[@]}" --namespace "$RAM_NAMESPACE" get configmap "$config_name" \
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

bearer = re.findall(r'(?m)^\s*skip_jwt_bearer_tokens\s*=\s*true\s*$', content)
if len(bearer) != 1:
    raise SystemExit("oauth2-proxy must have skip_jwt_bearer_tokens = true.")
issuers = re.compile(r'(?m)^(\s*extra_jwt_issuers\s*=\s*)([^\r\n]+)$')
existing = list(issuers.finditer(content))
desired = '"' + os.environ["ISSUER_URI"] + '/oauth/token=openid"'
if len(existing) > 1 or (existing and existing[0].group(2).strip() != desired):
    raise SystemExit("oauth2-proxy has a different extra_jwt_issuers value.")
if not existing:
    content = content.rstrip("\n") + "\nextra_jwt_issuers = " + desired + "\n"
config_file.write_text(content)
PY

if ! cmp -s "$config_file" "$temporary_directory/original.cfg"; then
  "${KUBECTL[@]}" --namespace "$RAM_NAMESPACE" create configmap "$config_name" \
    --from-file="oauth2-proxy.cfg=$config_file" --dry-run=client -o yaml \
    | "${KUBECTL[@]}" --namespace "$RAM_NAMESPACE" apply -f -
  for deployment in "${RAM_RELEASE}-api" "${RAM_RELEASE}-app"; do
    "${KUBECTL[@]}" --namespace "$RAM_NAMESPACE" rollout restart "deployment/$deployment"
    "${KUBECTL[@]}" --namespace "$RAM_NAMESPACE" rollout status \
      "deployment/$deployment" --timeout=180s
  done
fi

printf 'Registering the user-authenticated SAS MCP tools server...\n'
bash "$SCRIPT_DIR/register-viya-mcp.sh"
printf 'Configured Viya SSO and requested the SAS MCP tools server deployment in RAM.\n'