#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
IMAGE_NAME=${RAM_VIYA_IMAGE:-ram-viya-connect:local}
KUBECONFIG_PATH=${KUBECONFIG_PATH:-${KUBECONFIG:-${HOME}/.kube/config}}

usage() {
  cat <<'EOF'
Connect SAS Viya identity and its MCP tools server to an existing RAM cluster.

Usage: run-viya-connection.sh --context CONTEXT --env-file FILE [--kubeconfig FILE]

The environment file must contain VIYA_URL, VIYA_USER, VIYA_PASSWORD,
VIYA_CLIENT_SECRET, RAM_URL, RAM_KC_PASSWORD, and MCP_IMAGE.
EOF
}

die() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

kube_context=
environment_file=
while (( $# > 0 )); do
  case "$1" in
    --context|--env-file|--kubeconfig)
      [[ -n "${2:-}" ]] || die "$1 requires a value."
      case "$1" in
        --context) kube_context=$2 ;;
        --env-file) environment_file=$2 ;;
        --kubeconfig) KUBECONFIG_PATH=$2 ;;
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

[[ -n "$kube_context" ]] || die '--context is required.'
[[ -n "$environment_file" && -f "$environment_file" ]] \
  || die '--env-file must name a file.'
[[ "$KUBECONFIG_PATH" != *:* && -f "$KUBECONFIG_PATH" ]] \
  || die 'Use one existing Kubernetes configuration file.'

for executable in docker jq kubectl; do
  command -v "$executable" >/dev/null 2>&1 || die "$executable is required."
done
docker info >/dev/null 2>&1 || die 'Docker is not available.'

umask 077
raw_config=$(mktemp)
runtime_token=$(mktemp)
converted_config=$(mktemp)
trap 'rm -f "$raw_config" "$runtime_token" "$converted_config"' EXIT

kubectl --kubeconfig "$KUBECONFIG_PATH" --context "$kube_context" \
  config view --raw --flatten --minify --output json >"$raw_config" \
  || die "Could not read Kubernetes context $kube_context."
jq -e --arg context "$kube_context" '.contexts[0].name == $context' \
  "$raw_config" >/dev/null || die "Kubernetes context $kube_context was not found."

exec_command=$(jq -r '.users[0].user.exec.command // empty' "$raw_config")
login_mode=$(jq -r '
  (.users[0].user.exec.args // []) as $args
  | ($args | index("--login")) as $index
  | if $index == null then "" else $args[$index + 1] end
' "$raw_config")
runtime_config=$raw_config
if [[ "${exec_command##*/}" == kubelogin && "$login_mode" == azurecli ]]; then
  command -v az >/dev/null 2>&1 || die 'Azure CLI is required for this context.'
  command -v kubelogin >/dev/null 2>&1 || die 'kubelogin is required for this context.'
  mapfile -t login_args < <(jq -r '.users[0].user.exec.args[]' "$raw_config")
  kubelogin "${login_args[@]}" | jq -er '.status.token' >"$runtime_token" \
    || die 'Could not get the Kubernetes access token.'
  jq --rawfile token "$runtime_token" '
    (.users[0].user) |= (del(.exec, ."auth-provider")
      + {token: ($token | gsub("[\\r\\n]"; ""))})
  ' "$raw_config" >"$converted_config"
  runtime_config=$converted_config
elif [[ -n "$exec_command" && "${exec_command##*/}" != kubelogin ]]; then
  die "The container cannot run Kubernetes login command $exec_command."
fi

docker build --tag "$IMAGE_NAME" --file "$SCRIPT_DIR/lib/Dockerfile.viya" "$SCRIPT_DIR/lib"
tty_args=()
if [[ -t 0 && -t 1 ]]; then
  tty_args=(-t)
fi
docker run --rm --interactive "${tty_args[@]}" --network host \
  --volume "$runtime_config:/root/.kube/config:ro" \
  --env-file "$environment_file" --env "KUBE_CONTEXT=$kube_context" \
  "$IMAGE_NAME"