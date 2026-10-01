#!/usr/bin/env bash

set -euo pipefail

IMAGE_NAME=ram-connect-viya
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
KUBECONFIG_PATH=${KUBECONFIG_PATH:-${HOME}/.kube/config}
REBUILD_IMAGE=${RAM_CONNECT_VIYA_REBUILD:-false}
RUNTIME_KUBECONFIG=
RUNTIME_TOKEN=

command -v docker >/dev/null 2>&1 || {
  printf 'Error: Docker is required.\n' >&2
  exit 1
}
docker info >/dev/null 2>&1 || {
  printf 'Error: Docker is not available. Start Docker and run the command again.\n' >&2
  exit 1
}
[[ -f "$KUBECONFIG_PATH" ]] || {
  printf 'Error: Kubernetes configuration file not found: %s\n' "$KUBECONFIG_PATH" >&2
  printf 'Set KUBECONFIG_PATH to the correct absolute path.\n' >&2
  exit 1
}

current_context=$(kubectl config current-context 2>/dev/null) \
  || { printf 'Error: Could not read the current Kubernetes context.\n' >&2; exit 1; }
current_user=$(kubectl config view --raw -o json 2>/dev/null \
  | jq -er --arg context "$current_context" \
    'first(.contexts[] | select(.name == $context) | .context.user)') \
  || { printf 'Error: Could not read the user for the current Kubernetes context.\n' >&2; exit 1; }
exec_command=$(kubectl config view --raw -o json 2>/dev/null \
  | jq -er --arg user "$current_user" \
    'first(.users[] | select(.name == $user) | .user.exec.command)') \
  || exec_command=
login_mode=$(kubectl config view --raw -o json 2>/dev/null \
  | jq -er --arg user "$current_user" \
    'first(.users[] | select(.name == $user) | .user.exec.args) as $args
     | first($args | range(0; length - 1) as $i
       | select($args[$i] == "--login") | $args[$i + 1])') \
  || login_mode=

if [[ "$exec_command" == kubelogin && "$login_mode" == azurecli ]]; then
  command -v az >/dev/null 2>&1 \
    || { printf 'Error: Azure CLI is required for the current Kubernetes login.\n' >&2; exit 1; }
  command -v kubelogin >/dev/null 2>&1 \
    || { printf 'Error: kubelogin is required for the current Kubernetes login.\n' >&2; exit 1; }
  server_id=$(kubectl config view --raw -o json 2>/dev/null \
    | jq -er --arg user "$current_user" \
      'first(.users[] | select(.name == $user) | .user.exec.args) as $args
       | first($args | range(0; length - 1) as $i
         | select($args[$i] == "--server-id") | $args[$i + 1])') \
    || { printf 'Error: The current Kubernetes login has no server ID.\n' >&2; exit 1; }
  RUNTIME_KUBECONFIG=$(mktemp)
  RUNTIME_TOKEN=$(mktemp)
  trap 'rm -f "$RUNTIME_KUBECONFIG" "$RUNTIME_TOKEN"' EXIT
  kubelogin get-token --login azurecli --server-id "$server_id" \
    | jq -er '.status.token' | tr -d '\r\n' >"$RUNTIME_TOKEN" \
    || { printf 'Error: Could not get an Azure Kubernetes token.\n' >&2; exit 1; }
  [[ -s "$RUNTIME_TOKEN" ]] \
    || { printf 'Error: Azure Kubernetes token is empty.\n' >&2; exit 1; }
  kubectl config view --raw -o json \
    | jq --arg user "$current_user" --rawfile token "$RUNTIME_TOKEN" \
      '(.users[] | select(.name == $user) | .user)
       |= (del(.exec, ."auth-provider") + {token: $token})' \
    >"$RUNTIME_KUBECONFIG"
  KUBECONFIG_PATH=$RUNTIME_KUBECONFIG
fi

container_args=()
docker_mounts=(-v "$KUBECONFIG_PATH:/root/.kube/config:ro")
while (( $# > 0 )); do
  case "$1" in
    --ca-file)
      [[ -n "${2:-}" ]] || {
        printf 'Error: --ca-file requires a value.\n' >&2
        exit 1
      }
      [[ -f "$2" ]] || {
        printf 'Error: CA certificate file not found: %s\n' "$2" >&2
        exit 1
      }
      ca_directory=$(cd "$(dirname "$2")" && pwd)
      ca_path="$ca_directory/$(basename "$2")"
      docker_mounts+=(-v "$ca_path:/opt/ram-connect-viya-ca/ca.crt:ro")
      container_args+=(--ca-file /opt/ram-connect-viya-ca/ca.crt)
      shift 2
      ;;
    *)
      container_args+=("$1")
      shift
      ;;
  esac
done

if [[ "$REBUILD_IMAGE" == true ]] \
  || ! docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
  docker build --tag "$IMAGE_NAME" "$SCRIPT_DIR"
fi

docker run --rm --interactive --tty \
  "${docker_mounts[@]}" \
  "$IMAGE_NAME" \
  "${container_args[@]}"
