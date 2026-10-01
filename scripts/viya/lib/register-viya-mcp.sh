#!/usr/bin/env bash

set -euo pipefail

if [[ "${1:-}" == --help || "${1:-}" == -h ]]; then
  printf 'Register the user-authenticated SAS MCP tools server in an existing RAM cluster.\n'
  exit 0
fi
(( $# == 0 )) || { printf 'Unknown option: %s\n' "$1" >&2; exit 2; }

die() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

for name in VIYA_URL RAM_URL KUBE_CONTEXT MCP_IMAGE; do
  [[ -n "${!name:-}" ]] || die "Required environment variable unset: $name"
done
RAM_NAMESPACE=${RAM_NAMESPACE:-retagentmgr}
RAM_RELEASE=${RAM_RELEASE:-retrieval-agent-manager}
RAM_KC_REALM=${RAM_KC_REALM:-sas-iot}
RAM_KC_CLIENT_ID=${RAM_KC_CLIENT_ID:-sas-ram-app}
IDP_ALIAS=${IDP_ALIAS:-viya-oidc}
RAM_API_URL="$RAM_URL/SASRetrievalAgentManager/api/v1"
MCP_NAME='user-authenticated sas-mcp-tools'
KUBECTL=(kubectl --context "$KUBE_CONTEXT" --namespace "$RAM_NAMESPACE")

for executable in base64 curl jq kubectl python3; do
  command -v "$executable" >/dev/null 2>&1 || die "$executable is required."
done
umask 077
temporary_directory=$(mktemp -d)
trap 'rm -rf "$temporary_directory"' EXIT
response_file="$temporary_directory/response.json"

secret_value() {
  local secret_name=$1 secret_key=$2 secret_json
  secret_json=$("${KUBECTL[@]}" get secret "$secret_name" -o json) \
    || die "Could not read Secret $RAM_NAMESPACE/$secret_name."
  printf '%s' "$secret_json" | jq -er --arg key "$secret_key" '.data[$key] // empty' \
    | base64 --decode || die "Secret $RAM_NAMESPACE/$secret_name has no $secret_key value."
}

api_request() {
  local method=$1 endpoint=$2 body_file=${3:-} http_status
  local arguments=(-X "$method" -H "Authorization: Bearer $RAM_API_TOKEN")
  if [[ -n "$body_file" ]]; then
    arguments+=(-H 'Content-Type: application/json' --data-binary "@$body_file")
  fi
  http_status=$(curl -ksS -o "$response_file" -w '%{http_code}' \
    "${arguments[@]}" "$RAM_API_URL/$endpoint") \
    || die "RAM request failed: $method $endpoint."
  case "$http_status" in
    200|201|202|204) ;;
    *) die "RAM request failed: $method $endpoint (HTTP $http_status)." ;;
  esac
}

api_lookup() {
  local endpoint=$1 http_status
  http_status=$(curl -ksS -o "$response_file" -w '%{http_code}' \
    -H "Authorization: Bearer $RAM_API_TOKEN" --get \
    --data-urlencode "filter=and(eq(name,$MCP_NAME),eq(type,container))" \
    --data-urlencode 'limit=1' "$RAM_API_URL/$endpoint") \
    || die "RAM lookup failed: $endpoint."
  [[ "$http_status" == 200 ]] || die "RAM lookup failed: $endpoint (HTTP $http_status)."
}

client_secret_name="${RAM_RELEASE}-keycloak-client-secret"
appadmin_secret_name="${RAM_RELEASE}-keycloak-appadmin-secret"
realm=$(secret_value "$client_secret_name" realm)
client_id=$(secret_value "$client_secret_name" sv-client-id)
client_secret=$(secret_value "$client_secret_name" sv-client-secret)
appadmin_user=$(secret_value "$appadmin_secret_name" user)
appadmin_password=$(secret_value "$appadmin_secret_name" password)
[[ "$realm" == "$RAM_KC_REALM" ]] || die 'RAM_KC_REALM does not match the RAM Secret.'
[[ "$client_id" == "$RAM_KC_CLIENT_ID" ]] || die 'RAM_KC_CLIENT_ID does not match the RAM Secret.'

http_status=$(curl -ksS -o "$response_file" -w '%{http_code}' \
  -X POST "$RAM_URL/SASRetrievalAgentManager/auth/realms/$realm/protocol/openid-connect/token" \
  -u "$client_id:$client_secret" --data-urlencode 'grant_type=password' \
  --data-urlencode "username=$appadmin_user" \
  --data-urlencode "password=$appadmin_password") \
  || die 'Could not authenticate with the RAM application client.'
unset client_secret appadmin_password
[[ "$http_status" == 200 ]] || die "RAM application authentication failed (HTTP $http_status)."
RAM_API_TOKEN=$(jq -er '.access_token // empty' "$response_file") \
  || die 'RAM application authentication returned no access token.'

api_lookup toolServerTemplates
template_id=$(jq -r '.items[0].id // empty' "$response_file")
template_version=$(jq -r '.items[0].version // empty' "$response_file")
if [[ -n "$template_id" ]]; then
  [[ "$template_version" =~ ^[0-9]+$ ]] || die 'The RAM MCP template has no valid version.'
  api_request GET "toolServerTemplates/$template_id/$template_version"
  jq -e --arg image "$MCP_IMAGE" --arg alias "$IDP_ALIAS" '
    .metadata.image == $image and (.metadata.port | tostring) == "8134"
    and .metadata.transport == "http" and .metadata.basepath == "/mcp"
    and .metadata.auth == "identity_broker"
    and .secrets.auth_credentials.identity_broker_alias == $alias
  ' "$response_file" >/dev/null || die "RAM MCP template '$MCP_NAME' has conflicting configuration."
  template_state=$(jq -r '.published_state // empty' "$response_file")
  printf 'Found RAM MCP template %s.\n' "$MCP_NAME"
else
  template_id=$(python3 -c 'import uuid; print(uuid.uuid4())')
  jq -n --arg id "$template_id" --arg name "$MCP_NAME" \
    --arg image "$MCP_IMAGE" --arg alias "$IDP_ALIAS" '{
    id: $id, name: $name,
    description: "SAS MCP Server container tools that use the authenticated user token.",
    type: "container", published_state: "unpublished", version: 0,
    template_type: "tool_container",
    metadata: {auth: "identity_broker", port: 8134, image: $image,
      basepath: "/mcp", transport: "http",
      resources: {req_cpu: 0.5, req_mem: "512Mi"}},
    secrets: {auth_credentials: {identity_broker_alias: $alias},
      extra_auth_headers: {}, env_vars: [
        {name: "VIYA_ENDPOINT", description: "Viya deployment URL.", required: false, default: "", secret: false},
        {name: "ALLOW_RAW_BEARER", description: "Allow raw bearer tokens.", required: false, default: "true", secret: false}
      ], args: null, credentials: {username: null, password: null}},
    files: {files: [{path: "/tmp/config/tools.yaml", content: "# SAS MCP server configuration\n"}]}
  }' >"$temporary_directory/template.json"
  api_request POST toolServerTemplates "$temporary_directory/template.json"
  template_id=$(jq -r '.toolServerTemplateId // empty' "$response_file")
  template_version=$(jq -r '.version // empty' "$response_file")
  [[ -n "$template_id" && "$template_version" =~ ^[0-9]+$ ]] \
    || die 'RAM did not return the new MCP template ID and version.'
  template_state=unpublished
  printf 'Created RAM MCP template %s.\n' "$MCP_NAME"
fi

if [[ "$template_state" != published ]]; then
  api_request PUT "toolServerTemplates/$template_id/$template_version/published"
  printf 'Published RAM MCP template %s.\n' "$MCP_NAME"
fi

api_lookup toolServers
server_id=$(jq -r '.items[0].id // empty' "$response_file")
if [[ -n "$server_id" ]]; then
  api_request GET "toolServers/$server_id"
  jq -e --arg template_id "$template_id" --argjson version "$template_version" \
    --arg alias "$IDP_ALIAS" --arg viya_url "$VIYA_URL" '
    .template_id == $template_id and .template_version == $version
    and .metadata.auth == "identity_broker"
    and .secrets.auth_credentials.identity_broker_alias == $alias
    and any(.secrets.env_vars[]?; .name == "VIYA_ENDPOINT" and .value == $viya_url)
    and any(.secrets.env_vars[]?; .name == "ALLOW_RAW_BEARER" and .value == "true")
  ' "$response_file" >/dev/null || die "RAM MCP server '$MCP_NAME' has conflicting configuration."
  printf 'Found RAM MCP server %s.\n' "$MCP_NAME"
else
  server_id=$(python3 -c 'import uuid; print(uuid.uuid4())')
  jq -n --arg id "$server_id" --arg name "$MCP_NAME" \
    --arg template_id "$template_id" --argjson version "$template_version" \
    --arg viya_url "$VIYA_URL" --arg alias "$IDP_ALIAS" '{
    id: $id, name: $name,
    description: "SAS MCP Server container tools that use the authenticated user token.",
    template_id: $template_id, template_version: $version,
    type: "container", template_type: "tool_container",
    metadata: {auth: "identity_broker"},
    secrets: {auth_credentials: {identity_broker_alias: $alias},
      extra_auth_headers: {}, env_vars: [
        {name: "VIYA_ENDPOINT", value: $viya_url, description: "Viya deployment URL.", secret: false},
        {name: "ALLOW_RAW_BEARER", value: "true", description: "Allow raw bearer tokens.", secret: false}
      ]}
  }' >"$temporary_directory/server.json"
  api_request POST toolServers "$temporary_directory/server.json"
  printf 'Created RAM MCP server %s.\n' "$MCP_NAME"
fi

deployment_selector="sas-retagentmgr/tool-server-id=$server_id"
deployment_name=$("${KUBECTL[@]}" get deployments --selector "$deployment_selector" \
  -o name) || die 'Could not read the MCP deployment.'
if [[ -z "$deployment_name" ]]; then
  api_request PUT "toolServers/$server_id/deployment"
  "${KUBECTL[@]}" wait --for=create deployment --selector "$deployment_selector" \
    --timeout=180s || die 'RAM did not create the MCP deployment.'
  deployment_name=$("${KUBECTL[@]}" get deployments --selector "$deployment_selector" \
    -o name) || die 'Could not read the new MCP deployment.'
fi
[[ -n "$deployment_name" && "$deployment_name" != *$'\n'* ]] \
  || die 'Expected one MCP deployment for this server.'
"${KUBECTL[@]}" rollout status "$deployment_name" --timeout=180s \
  || die 'The MCP deployment did not become available.'
printf 'RAM MCP server %s is available.\n' "$MCP_NAME"