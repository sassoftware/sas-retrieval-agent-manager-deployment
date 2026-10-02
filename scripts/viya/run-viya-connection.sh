#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
IMAGE_NAME=${RAM_VIYA_IMAGE:-ram-viya-connect:local}
DEFAULT_KUBECONFIG_PATH=${KUBECONFIG_PATH:-${KUBECONFIG:-${HOME}/.kube/config}}

usage() {
  cat <<'EOF'
Connect SAS Viya identity and its MCP tools server to an existing RAM cluster.

Usage: run-viya-connection.sh --env-file FILE [--context CONTEXT]
  [--ram-context CONTEXT] [--viya-context CONTEXT]
  [--kubeconfig FILE] [--ram-kubeconfig FILE] [--viya-kubeconfig FILE]

The environment file must contain VIYA_URL, VIYA_USER, VIYA_PASSWORD,
VIYA_CLIENT_SECRET, RAM_URL, RAM_KC_PASSWORD, and MCP_IMAGE.
EOF
}

die() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

shared_context=
ram_context=
viya_context=
shared_kubeconfig=$DEFAULT_KUBECONFIG_PATH
ram_kubeconfig=
viya_kubeconfig=
environment_file=
while (( $# > 0 )); do
  case "$1" in
    --context|--ram-context|--viya-context|--env-file|--kubeconfig|--ram-kubeconfig|--viya-kubeconfig)
      [[ -n "${2:-}" ]] || die "$1 requires a value."
      case "$1" in
        --context) shared_context=$2 ;;
        --ram-context) ram_context=$2 ;;
        --viya-context) viya_context=$2 ;;
        --env-file) environment_file=$2 ;;
        --kubeconfig) shared_kubeconfig=$2 ;;
        --ram-kubeconfig) ram_kubeconfig=$2 ;;
        --viya-kubeconfig) viya_kubeconfig=$2 ;;
      esac
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *) die "Unknown option: $1" ;;
  esac
done

ram_context=${ram_context:-$shared_context}
viya_context=${viya_context:-$shared_context}
ram_kubeconfig=${ram_kubeconfig:-$shared_kubeconfig}
viya_kubeconfig=${viya_kubeconfig:-$shared_kubeconfig}
[[ -n "$ram_context" ]] || die 'Set --context or --ram-context.'
[[ -n "$viya_context" ]] || die 'Set --context or --viya-context.'
[[ -n "$environment_file" && -f "$environment_file" ]] \
  || die '--env-file must name a file.'
[[ "$ram_kubeconfig" != *:* && -f "$ram_kubeconfig" \
  && "$viya_kubeconfig" != *:* && -f "$viya_kubeconfig" ]] \
  || die 'Use one existing Kubernetes configuration file for each cluster.'

for executable in docker jq kubectl; do
  command -v "$executable" >/dev/null 2>&1 || die "$executable is required."
done
docker info >/dev/null 2>&1 || die 'Docker is not available.'

umask 077
temporary_directory=$(mktemp -d)
trap 'rm -rf "$temporary_directory"' EXIT
runtime_token="$temporary_directory/runtime-token"
raw_ram_config="$temporary_directory/raw-ram-config.json"
raw_viya_config="$temporary_directory/raw-viya-config.json"
runtime_ram_config="$temporary_directory/ram-config.json"
runtime_viya_config="$temporary_directory/viya-config.json"

prepare_runtime_config() {
  local source_config="$1"
  local context="$2"
  local raw_config="$3"
  local runtime_config="$4"
  local exec_command
  local login_mode

  kubectl --kubeconfig "$source_config" --context "$context" \
    config view --raw --flatten --minify --output json >"$raw_config" \
    || die "Could not read Kubernetes context $context."
  jq -e --arg context "$context" '.contexts[0].name == $context' \
    "$raw_config" >/dev/null || die "Kubernetes context $context was not found."

  exec_command=$(jq -r '.users[0].user.exec.command // empty' "$raw_config")
  login_mode=$(jq -r '
    (.users[0].user.exec.args // []) as $args
    | ($args | index("--login")) as $index
    | if $index == null then "" else $args[$index + 1] end
  ' "$raw_config")
  if [[ "${exec_command##*/}" == kubelogin && "$login_mode" == azurecli ]]; then
    command -v az >/dev/null 2>&1 || die 'Azure CLI is required for this context.'
    command -v kubelogin >/dev/null 2>&1 || die 'kubelogin is required for this context.'
    mapfile -t login_args < <(jq -r '.users[0].user.exec.args[]' "$raw_config")
    kubelogin "${login_args[@]}" | jq -er '.status.token' >"$runtime_token" \
      || die 'Could not get the Kubernetes access token.'
    jq --rawfile token "$runtime_token" '
      (.users[0].user) |= (del(.exec, ."auth-provider")
        + {token: ($token | gsub("[\\r\\n]"; ""))})
    ' "$raw_config" >"$runtime_config"
  elif [[ -n "$exec_command" && "${exec_command##*/}" != kubelogin ]]; then
    die "The container cannot run Kubernetes login command $exec_command."
  else
    cp "$raw_config" "$runtime_config"
  fi
}

prepare_runtime_config "$ram_kubeconfig" "$ram_context" \
  "$raw_ram_config" "$runtime_ram_config"
prepare_runtime_config "$viya_kubeconfig" "$viya_context" \
  "$raw_viya_config" "$runtime_viya_config"

docker build --tag "$IMAGE_NAME" --file "$SCRIPT_DIR/lib/Dockerfile.viya" "$SCRIPT_DIR/lib"
tty_args=()
if [[ -t 0 && -t 1 ]]; then
  tty_args=(-t)
fi
docker run --rm --interactive "${tty_args[@]}" --network host \
  --volume "$runtime_ram_config:/root/.kube/ram-config:ro" \
  --volume "$runtime_viya_config:/root/.kube/viya-config:ro" \
  --env-file "$environment_file" \
  --env "RAM_KUBE_CONTEXT=$ram_context" \
  --env "VIYA_KUBE_CONTEXT=$viya_context" \
  --env 'RAM_KUBECONFIG=/root/.kube/ram-config' \
  --env 'VIYA_KUBECONFIG=/root/.kube/viya-config' \
  "$IMAGE_NAME"