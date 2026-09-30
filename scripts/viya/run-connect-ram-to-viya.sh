#!/usr/bin/env bash

set -euo pipefail

IMAGE_NAME=ram-connect-viya
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
KUBECONFIG_PATH=${KUBECONFIG_PATH:-${HOME}/.kube/config}
REBUILD_IMAGE=${RAM_CONNECT_VIYA_REBUILD:-false}

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
