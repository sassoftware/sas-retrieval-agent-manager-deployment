#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"
# shellcheck source=lib/sso.sh
source "$SCRIPT_DIR/lib/sso.sh"
# shellcheck source=lib/home-directories.sh
source "$SCRIPT_DIR/lib/home-directories.sh"
# shellcheck source=lib/mcp.sh
source "$SCRIPT_DIR/lib/mcp.sh"
# shellcheck source=lib/application-registration.sh
source "$SCRIPT_DIR/lib/application-registration.sh"

usage() {
  cat <<'EOF'
Connect SAS Retrieval Agent Manager to SAS Viya.

Usage:
  connect-ram-to-viya.sh \
    --context CONTEXT \
    --viya-url https://viya.example.com \
    --ram-url https://ram.example.com \
    --mcp-image IMAGE:TAG \
    [options]

Required options:
  --viya-url URL             External SAS Viya URL
  --ram-url URL              External RAM URL

Required for the full workflow and --mcp-only:
  --mcp-image IMAGE:TAG      SAS MCP server image with a tag or digest

Options:
  --context CONTEXT          Expected Kubernetes context (default: current context)
  --ram-namespace NAME       RAM namespace (default: retagentmgr)
  --viya-namespace NAME      SAS Viya namespace (default: viya)
  --release NAME             RAM Helm release (default: retrieval-agent-manager)
  --ca-file FILE             CA certificate bundle for RAM and SAS Viya HTTPS
  --viya-user-group USER:GROUP
                             Add a Viya user to a group after SSO setup
  --sso-only                 Run only the SAS Logon and RAM SSO stages
  --mcp-only                 Run only the MCP stages after verifying SSO
  --check-only               Verify an existing connection without changes
  -h, --help                 Show this help

The script requests the SAS boot and RAM Keycloak administrator passwords in
the terminal. Do not enter either password as a command-line argument.
EOF
}

KUBE_CONTEXT=
VIYA_URL=
RAM_URL=
MCP_IMAGE=
RAM_NAMESPACE=retagentmgr
VIYA_NAMESPACE=viya
RAM_RELEASE=retrieval-agent-manager
CA_CERT=
CHECK_ONLY=false
WORKFLOW_MODE=full
VIYA_GROUP_MEMBERSHIPS=()

while (( $# > 0 )); do
  case "$1" in
    --context)
      require_value "$1" "${2:-}"
      KUBE_CONTEXT=$2
      shift 2
      ;;
    --viya-url)
      require_value "$1" "${2:-}"
      VIYA_URL=$2
      shift 2
      ;;
    --ram-url)
      require_value "$1" "${2:-}"
      RAM_URL=$2
      shift 2
      ;;
    --mcp-image)
      require_value "$1" "${2:-}"
      MCP_IMAGE=$2
      shift 2
      ;;
    --ram-namespace)
      require_value "$1" "${2:-}"
      RAM_NAMESPACE=$2
      shift 2
      ;;
    --viya-namespace)
      require_value "$1" "${2:-}"
      VIYA_NAMESPACE=$2
      shift 2
      ;;
    --release)
      require_value "$1" "${2:-}"
      RAM_RELEASE=$2
      shift 2
      ;;
    --ca-file)
      require_value "$1" "${2:-}"
      CA_CERT=$2
      shift 2
      ;;
    --viya-user-group)
      require_value "$1" "${2:-}"
      VIYA_GROUP_MEMBERSHIPS+=("$2")
      shift 2
      ;;
    --sso-only)
      [[ "$WORKFLOW_MODE" == full ]] || die "--sso-only and --mcp-only cannot be used together."
      WORKFLOW_MODE=sso
      shift
      ;;
    --mcp-only)
      [[ "$WORKFLOW_MODE" == full ]] || die "--sso-only and --mcp-only cannot be used together."
      WORKFLOW_MODE=mcp
      shift
      ;;
    --check-only)
      CHECK_ONLY=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "Unknown option: $1"
      ;;
  esac
done

if [[ -z "$KUBE_CONTEXT" ]]; then
  KUBE_CONTEXT=$(kubectl config current-context 2>/dev/null) \
    || die "Could not read the current Kubernetes context."
  [[ -n "$KUBE_CONTEXT" ]] || die "The current Kubernetes context is empty."
fi

[[ -n "$VIYA_URL" ]] || die "--viya-url is required."
[[ -n "$RAM_URL" ]] || die "--ram-url is required."
if [[ "$WORKFLOW_MODE" != sso ]]; then
  [[ -n "$MCP_IMAGE" ]] || die "--mcp-image is required unless --sso-only is used."
fi

VIYA_URL=$(trim_url "$VIYA_URL")
RAM_URL=$(trim_url "$RAM_URL")
validate_https_url --viya-url "$VIYA_URL"
validate_https_url --ram-url "$RAM_URL"
[[ "$VIYA_URL" =~ ^https://[^/?#[:space:]]+$ ]] \
  || die "--viya-url must contain only a scheme and host."
[[ "$RAM_URL" =~ ^https://[^/?#[:space:]]+$ ]] \
  || die "--ram-url must contain only a scheme and host."
validate_kubernetes_name RAM_NAMESPACE "$RAM_NAMESPACE"
validate_kubernetes_name VIYA_NAMESPACE "$VIYA_NAMESPACE"
validate_kubernetes_name RAM_RELEASE "$RAM_RELEASE"
[[ "$KUBE_CONTEXT" != *$'\n'* && "$KUBE_CONTEXT" != *$'\r'* ]] \
  || die "--context cannot contain a newline."
if [[ -n "$MCP_IMAGE" ]]; then
  [[ "$MCP_IMAGE" == *@sha256:* || "$MCP_IMAGE" == *:* ]] \
    || die "--mcp-image must include a tag or digest."
fi

VIYA_USER=sasboot
RAM_KC_USER=kcAdmin
RAM_KC_CLIENT_ID=sas-ram-app
IDP_ALIAS=viya-oidc
RAM_KC_ADMIN_GROUP=Admin
RAM_KC_USER_GROUP=User
VIYA_SSO_CLIENT_ID=ram-client
VIYA_MCP_CLIENT_ID=ram-app
VIYA_SSO_SECRET_NAME="${RAM_RELEASE}-viya-sso-client-secret"
VIYA_MCP_SECRET_NAME="${RAM_RELEASE}-viya-mcp-client-secret"
ISSUER_URI="$RAM_URL/SASLogon"
VIYA_PASSWORD=
RAM_KC_PASSWORD=
HOME_RESOURCES_CREATED=false

for executable in base64 cmp curl helm jq kubectl openssl python3 sed tr; do
  require_command "$executable"
done

init_temporary_directory
trap 'cleanup_home_directory_resources; cleanup_temporary_directory' EXIT
configure_tls

verify_kubernetes_target
kubectl_cmd get namespace "$RAM_NAMESPACE" >/dev/null \
  || die "RAM namespace '$RAM_NAMESPACE' does not exist."
kubectl_cmd get namespace "$VIYA_NAMESPACE" >/dev/null \
  || die "Viya namespace '$VIYA_NAMESPACE' does not exist."
if [[ "$WORKFLOW_MODE" != mcp ]]; then
  kubectl_cmd auth can-i get pods --namespace "$VIYA_NAMESPACE" | grep -q '^yes$' \
    || die "The current Kubernetes identity cannot read pods in '$VIYA_NAMESPACE'."
  kubectl_cmd auth can-i delete pods --namespace "$VIYA_NAMESPACE" | grep -q '^yes$' \
    || die "The current Kubernetes identity cannot restart SAS Logon pods in '$VIYA_NAMESPACE'."
fi
helm status "$RAM_RELEASE" --namespace "$RAM_NAMESPACE" \
  --kube-context "$KUBE_CONTEXT" >/dev/null \
  || die "RAM Helm release '$RAM_NAMESPACE/$RAM_RELEASE' is not ready."

permissions=('get secrets' 'create secrets')
if [[ "$WORKFLOW_MODE" != mcp ]]; then
  permissions+=(
    'create configmaps'
    'patch configmaps'
    'patch deployments.apps'
  )
fi
if [[ "$WORKFLOW_MODE" == full ]]; then
  permissions+=('create jobs.batch' 'delete jobs.batch')
fi
for permission in "${permissions[@]}"; do
  verb=${permission%% *}
  resource=${permission#* }
  allowed=$(kubectl_cmd auth can-i "$verb" "$resource" --namespace "$RAM_NAMESPACE")
  [[ "$allowed" == yes ]] \
    || die "The current Kubernetes identity cannot $verb $resource in '$RAM_NAMESPACE'."
done

client_secret_name="${RAM_RELEASE}-keycloak-client-secret"
appadmin_secret_name="${RAM_RELEASE}-keycloak-appadmin-secret"
kubectl_cmd get secret "$client_secret_name" --namespace "$RAM_NAMESPACE" \
  --output name >/dev/null \
  || die "Required Secret '$RAM_NAMESPACE/$client_secret_name' does not exist."
if [[ "$WORKFLOW_MODE" != sso ]]; then
  kubectl_cmd get secret "$appadmin_secret_name" --namespace "$RAM_NAMESPACE" \
    --output name >/dev/null \
    || die "Required Secret '$RAM_NAMESPACE/$appadmin_secret_name' does not exist."
fi
RAM_KC_REALM=$(kubernetes_secret_value "$RAM_NAMESPACE" "$client_secret_name" realm)
[[ -n "$RAM_KC_REALM" ]] || die "The RAM Keycloak realm is empty."
validate_alias RAM_KC_REALM "$RAM_KC_REALM"

http_request GET "$RAM_URL/SASRetrievalAgentManager/oauth2/start" '' '' ''
[[ "$HTTP_STATUS" == 2* || "$HTTP_STATUS" == 3* ]] \
  || die "RAM did not return an expected response."
if [[ "$WORKFLOW_MODE" != mcp ]]; then
  http_request GET "$VIYA_URL/SASLogon/.well-known/openid-configuration" '' '' ''
  expect_http 'Connect to SAS Viya' 200
fi
if [[ "$WORKFLOW_MODE" == full ]]; then
  discover_viya_home_export
fi

printf '\nTarget summary\n'
printf '  Kubernetes context: %s\n' "$KUBE_CONTEXT"
printf '  RAM namespace: %s\n' "$RAM_NAMESPACE"
printf '  Viya namespace: %s\n' "$VIYA_NAMESPACE"
printf '  RAM Helm release: %s\n' "$RAM_RELEASE"
printf '  Viya URL: %s\n' "$VIYA_URL"
printf '  RAM URL: %s\n' "$RAM_URL"
printf '  Workflow: %s\n' "$WORKFLOW_MODE"
if [[ "$WORKFLOW_MODE" != mcp ]]; then
  printf '  SAS Logon issuer URI: %s\n' "$ISSUER_URI"
fi
if [[ "$WORKFLOW_MODE" != sso ]]; then
  printf '  MCP image: %s\n' "$MCP_IMAGE"
fi
if [[ "$WORKFLOW_MODE" == full ]]; then
  printf '  Viya NFS home export: %s:%s\n' "$HOME_NFS_SERVER" "$HOME_NFS_PATH"
fi

if [[ "$CHECK_ONLY" == false ]]; then
  cat <<'EOF'

  The script will configure these items:
EOF
  case "$WORKFLOW_MODE" in
    sso)
      printf '  SAS Logon issuer URI and RAM SSO configuration\n'
      printf '  RAM OAuth proxy ConfigMap and API/app rollouts\n'
      ;;
    mcp)
      printf '  Existing SSO verification\n'
      printf '  OAuth and user-token MCP templates and tools servers\n'
      ;;
    full)
      printf '  SAS Logon issuer URI and RAM SSO configuration\n'
      printf '  RAM OAuth proxy ConfigMap and API/app rollouts\n'
      printf '  Viya NFS home directories through a temporary privileged Job\n'
      printf '  OAuth and user-token MCP templates and tools servers\n'
      printf '  RAM entry in the Viya application menu\n'
      ;;
  esac
  confirm_changes
fi

prompt_secret VIYA_PASSWORD 'SAS boot password: '
prompt_secret RAM_KC_PASSWORD 'RAM Keycloak administrator password: '

case "$WORKFLOW_MODE" in
  sso)
    ensure_saslogon_issuer
    run_sso_setup
    ;;
  mcp)
    verify_sso_prerequisites
    run_mcp_setup
    ;;
  full)
    ensure_saslogon_issuer
    run_sso_setup
    run_home_directory_setup
    run_mcp_setup
    register_ram_application
    ;;
esac

if [[ "$CHECK_ONLY" == true ]]; then
  printf 'The RAM to Viya connection check is complete.\n'
else
  case "$WORKFLOW_MODE" in
    sso) printf 'RAM SSO with SAS Viya is configured.\n' ;;
    mcp) printf 'Both RAM MCP tools servers are configured.\n' ;;
    full) printf 'RAM is connected to SAS Viya. Both MCP tools servers are configured.\n' ;;
  esac
fi
