#!/usr/bin/env bash

set -euo pipefail

IMAGE_NAME='ram-mirror-images'
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPOSITORY_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <target-registry>" >&2
    exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
    echo 'ERROR: Docker is required but is not installed.' >&2
    exit 1
fi

echo "Building '$IMAGE_NAME' with the current mirror-images.sh."
docker build --tag "$IMAGE_NAME" "$SCRIPT_DIR"

docker_args=(
    run
    --rm
    -it
    --mount "type=bind,source=$REPOSITORY_ROOT/helm,target=/workspace/helm,readonly"
    --mount 'type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock'
)

docker_config_file="${DOCKER_CONFIG:-$HOME/.docker}/config.json"
if [[ -f "$docker_config_file" ]]; then
    docker_args+=(
        --mount "type=bind,source=$docker_config_file,target=/root/.docker/config.json,readonly"
    )
fi

azure_config_dir="${AZURE_CONFIG_DIR:-$HOME/.azure}"
if [[ -d "$azure_config_dir" ]]; then
    docker_args+=(
        --mount "type=bind,source=$azure_config_dir,target=/root/.azure"
    )
fi

docker_args+=("$IMAGE_NAME" "$@")
docker "${docker_args[@]}"