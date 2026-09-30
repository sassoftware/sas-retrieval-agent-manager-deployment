#!/usr/bin/env bash

set -euo pipefail

TEST_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
VIYA_DIR=$(cd "$TEST_DIR/.." && pwd)
TEMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/ram-viya-tests.XXXXXX")
trap 'rm -rf "$TEMP_DIR"' EXIT

pass_count=0

pass() {
  pass_count=$((pass_count + 1))
  printf 'ok %s - %s\n' "$pass_count" "$1"
}

fail() {
  printf 'not ok - %s\n' "$1" >&2
  exit 1
}

assert_file_contains() {
  local file=$1 pattern=$2 message=$3
  grep --quiet --fixed-strings -- "$pattern" "$file" || fail "$message"
}

for script in \
  "$VIYA_DIR/connect-ram-to-viya.sh" \
  "$VIYA_DIR/run-connect-ram-to-viya.sh" \
  "$VIYA_DIR/lib/common.sh" \
  "$VIYA_DIR/lib/sso.sh" \
  "$VIYA_DIR/lib/mcp.sh" \
  "$VIYA_DIR/lib/home-directories.sh" \
  "$VIYA_DIR/lib/application-registration.sh"; do
  bash -n "$script"
done
pass 'all Bash files have valid syntax'

help_output=$(bash "$VIYA_DIR/connect-ram-to-viya.sh" --help)
[[ "$help_output" == *'--context CONTEXT'* ]] || fail 'help does not show the context input'
[[ "$help_output" == *'--check-only'* ]] || fail 'help does not show check-only mode'
[[ "$help_output" == *'--sso-only'* ]] || fail 'help does not show sso-only mode'
[[ "$help_output" == *'--mcp-only'* ]] || fail 'help does not show mcp-only mode'
pass 'entry-point help shows required controls'

if bash "$VIYA_DIR/connect-ram-to-viya.sh" \
  --context test --viya-url https://viya.example.com \
  --ram-url https://ram.example.com \
  --mcp-image ghcr.io/sassoftware/sas-mcp-server:latest \
  >"$TEMP_DIR/latest.out" 2>&1; then
  fail 'the entry point accepted the latest MCP image tag'
fi
assert_file_contains "$TEMP_DIR/latest.out" 'must not use the mutable latest tag' \
  'latest image rejection did not explain the error'
pass 'the entry point rejects the latest MCP image tag'

if grep --extended-regexp --ignore-case --quiet \
  'subscription-id|resource-group|cluster-name|hosting-boundary' \
  "$VIYA_DIR/connect-ram-to-viya.sh" \
  "$VIYA_DIR/run-connect-ram-to-viya.sh" \
  "$VIYA_DIR/run-connect-ram-to-viya.ps1"; then
  fail 'an Azure infrastructure input is present'
fi
pass 'the wrappers do not require Azure infrastructure inputs'

mkdir "$TEMP_DIR/http-bin"
cat >"$TEMP_DIR/http-bin/curl" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$@" >"$HTTP_ARGUMENT_LOG"
printf '200'
EOF
chmod +x "$TEMP_DIR/http-bin/curl"

# shellcheck source=../lib/common.sh
source "$VIYA_DIR/lib/common.sh"
PATH="$TEMP_DIR/http-bin:$PATH"
export PATH
HTTP_ARGUMENT_LOG="$TEMP_DIR/http-arguments"
export HTTP_ARGUMENT_LOG
TEMPORARY_DIRECTORY="$TEMP_DIR/http"
mkdir "$TEMPORARY_DIRECTORY"
RESPONSE_FILE="$TEMPORARY_DIRECTORY/response"
HEADER_FILE="$TEMPORARY_DIRECTORY/headers"
CURL_TLS_ARGS=()
http_request POST https://example.com '' application/json \
  '{"client_secret":"must-not-be-an-argument"}'
if grep --quiet --fixed-strings 'must-not-be-an-argument' "$HTTP_ARGUMENT_LOG"; then
  fail 'a JSON secret was present in curl process arguments'
fi
assert_file_contains "$HTTP_ARGUMENT_LOG" '@/tmp/' \
  'curl did not receive a temporary request-body file'
pass 'JSON request bodies do not appear in process arguments'

# shellcheck source=../lib/mcp.sh
source "$VIYA_DIR/lib/mcp.sh"
MCP_IMAGE=ghcr.io/sassoftware/sas-mcp-server:1.0.0
VIYA_URL=https://viya.example.com
VIYA_MCP_CLIENT_ID=ram-app
VIYA_MCP_CLIENT_SECRET=test-secret
IDP_ALIAS=viya-oidc
TEMPLATE_CALL=0
SERVER_CALL=0

ensure_ram_template() {
  TEMPLATE_CALL=$((TEMPLATE_CALL + 1))
  printf '%s' "$2" >"$TEMP_DIR/template-$TEMPLATE_CALL.json"
  TEMPLATE_ID="template-$TEMPLATE_CALL"
  TEMPLATE_VERSION=1
}

ensure_ram_tool_server() {
  SERVER_CALL=$((SERVER_CALL + 1))
  printf '%s' "$2" >"$TEMP_DIR/server-$SERVER_CALL.json"
}

ensure_oauth_mcp_server
ensure_user_token_mcp_server
jq --exit-status \
  '.name == "sas-mcp-tools"
   and .metadata.auth == "client_credentials"
   and .metadata.image == "ghcr.io/sassoftware/sas-mcp-server:1.0.0"
   and .secrets.auth_credentials.client_secret == "test-secret"' \
  "$TEMP_DIR/template-1.json" >/dev/null \
  || fail 'the OAuth MCP template payload is invalid'
jq --exit-status \
  '.name == "user-authenticated sas-mcp-tools"
   and .metadata.auth == "identity_broker"
   and .secrets.auth_credentials.identity_broker_alias == "viya-oidc"' \
  "$TEMP_DIR/template-2.json" >/dev/null \
  || fail 'the user-token MCP template payload is invalid'
jq --exit-status \
  '.metadata.auth == "client_credentials"
   and .secrets.env_vars[0].value == "https://viya.example.com"' \
  "$TEMP_DIR/server-1.json" >/dev/null \
  || fail 'the OAuth MCP tools server payload is invalid'
jq --exit-status \
  '.metadata.auth == "identity_broker"
   and .secrets.auth_credentials.identity_broker_alias == "viya-oidc"' \
  "$TEMP_DIR/server-2.json" >/dev/null \
  || fail 'the user-token MCP tools server payload is invalid'
pass 'both MCP template and tools server payloads are valid'

mkdir -p "$TEMP_DIR/wrapper-bin" "$TEMP_DIR/home/.kube"
: >"$TEMP_DIR/home/.kube/config"
: >"$TEMP_DIR/ca.pem"
cat >"$TEMP_DIR/wrapper-bin/docker" <<'EOF'
#!/usr/bin/env bash
if [[ "${1:-}" == run ]]; then
  printf '%s\n' "$@" >"$DOCKER_ARGUMENT_LOG"
fi
exit 0
EOF
chmod +x "$TEMP_DIR/wrapper-bin/docker"
DOCKER_ARGUMENT_LOG="$TEMP_DIR/docker-arguments"
export DOCKER_ARGUMENT_LOG
PATH="$TEMP_DIR/wrapper-bin:$PATH" \
HOME="$TEMP_DIR/home" \
KUBECONFIG_PATH="$TEMP_DIR/home/.kube/config" \
bash "$VIYA_DIR/run-connect-ram-to-viya.sh" \
  --ca-file "$TEMP_DIR/ca.pem" --context expected-context \
  --viya-url https://viya.example.com --ram-url https://ram.example.com \
  --mcp-image ghcr.io/sassoftware/sas-mcp-server:1.0.0
assert_file_contains "$DOCKER_ARGUMENT_LOG" \
  "$TEMP_DIR/home/.kube/config:/root/.kube/config:ro" \
  'the wrapper did not mount the Kubernetes configuration read-only'
assert_file_contains "$DOCKER_ARGUMENT_LOG" \
  "$TEMP_DIR/ca.pem:/opt/ram-connect-viya-ca/ca.crt:ro" \
  'the wrapper did not mount the CA certificate read-only'
assert_file_contains "$DOCKER_ARGUMENT_LOG" 'expected-context' \
  'the wrapper did not forward the context'
pass 'the Linux wrapper mounts files and forwards arguments'

printf '1..%s\n' "$pass_count"
