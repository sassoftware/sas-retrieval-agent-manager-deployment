#!/usr/bin/env bash

set -u -o pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPOSITORY_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
HELM_DIR="$REPOSITORY_ROOT/helm"
RAM_CHART_NAME='sas-retrieval-agent-manager'
RAM_VALUES_FILE="$HELM_DIR/$RAM_CHART_NAME/values.yaml"

usage() {
    echo "Usage: $0 <target-registry>"
    echo
    echo "Mirror all SAS Retrieval Agent Manager and bundled chart images."
    echo "Azure Container Registry (ACR) targets use az acr import."
    echo "Other targets use Docker or Podman to pull, tag, and push images."
    echo "The script reads the main chart values and renders each bundled chart."
    echo
    echo "Arguments:"
    echo "  target-registry  Registry host, or an ACR name"
    echo
    echo "Prerequisites:"
    echo "  - Install Helm and mikefarah yq v4 or later."
    echo "  - For ACR, install Azure CLI and sign in with az login."
    echo "  - For other registries, install Docker or Podman and sign in to the target."
    echo "  - Have source credentials for cr.sas.com and docker.io when requested."
    echo
    echo "Examples:"
    echo "  $0 ramnoint1cr.azurecr.io"
    echo "  $0 registry.example.com"
    exit 1
}

if [[ $# -ne 1 ]]; then
    echo -e "${RED}ERROR: One target registry argument is required.${NC}\n"
    usage
fi

for command_name in helm yq; do
    if ! command -v "$command_name" >/dev/null 2>&1; then
        printf '%bERROR: %s is required but is not installed.%b\n' \
            "$RED" "$command_name" "$NC"
        exit 1
    fi
done

if ! yq --version 2>&1 | grep -Eq 'mikefarah|version v[0-9]'; then
    echo -e "${RED}ERROR: mikefarah yq v4+ required. Got: $(yq --version 2>&1)${NC}"
    echo "Install: https://github.com/mikefarah/yq/releases"
    exit 1
fi

TARGET_REGISTRY="${1#https://}"
TARGET_REGISTRY="${TARGET_REGISTRY%/}"
MIRROR_MODE='runtime'
ACR_NAME=''
ACR_LOGIN_SERVER=''
CONTAINER_RUNTIME=''
RUNTIME_AUTH_DIR=''

if [[ ! -f "$RAM_VALUES_FILE" ]]; then
    echo -e "${RED}ERROR: Main chart values file not found: ${RAM_VALUES_FILE}${NC}"
    exit 1
fi

if [[ "$TARGET_REGISTRY" == *.azurecr.io ||
    ("$TARGET_REGISTRY" != *.* && "$TARGET_REGISTRY" != *:*) ]]; then
    MIRROR_MODE='acr'
    ACR_NAME="${TARGET_REGISTRY%%.*}"

    if ! command -v az >/dev/null 2>&1; then
        echo -e "${RED}ERROR: az is required for an ACR target but is not installed.${NC}"
        exit 1
    fi

    if ! az account show >/dev/null 2>&1; then
        echo -e "${RED}ERROR: Sign in to Azure with az login.${NC}"
        exit 1
    fi

    ACR_LOGIN_SERVER=$(az acr show --name "$ACR_NAME" --query loginServer --output tsv 2>/dev/null)

    if [[ -z "$ACR_LOGIN_SERVER" ]]; then
        echo -e "${RED}ERROR: Azure Container Registry not found: ${ACR_NAME}${NC}"
        exit 1
    fi

    if [[ "$TARGET_REGISTRY" == *.* && "$TARGET_REGISTRY" != "$ACR_LOGIN_SERVER" ]]; then
        echo -e "${RED}ERROR: Registry login server is ${ACR_LOGIN_SERVER}, not ${TARGET_REGISTRY}.${NC}"
        exit 1
    fi

    TARGET_REGISTRY="$ACR_LOGIN_SERVER"
elif command -v docker >/dev/null 2>&1; then
    CONTAINER_RUNTIME='docker'
elif command -v podman >/dev/null 2>&1; then
    CONTAINER_RUNTIME='podman'
else
    echo -e "${RED}ERROR: Docker or Podman is required for a non-ACR target.${NC}"
    exit 1
fi

extract_workload_images() {
    yq eval '
                select(
                        .kind == "Deployment" or
                        .kind == "DaemonSet" or
                        .kind == "StatefulSet" or
                        .kind == "Job"
                )
                | .spec.template.spec.containers[]?.image,
                    .spec.template.spec.initContainers[]?.image,
                select(.kind == "Pod")
                | .spec.containers[]?.image,
                    .spec.initContainers[]?.image,
                    .spec.ephemeralContainers[]?.image,
                select(.kind == "CronJob")
                | .spec.jobTemplate.spec.template.spec.containers[]?.image,
                    .spec.jobTemplate.spec.template.spec.initContainers[]?.image
    ' - 2>/dev/null | sed -e '/^null$/d' -e '/^---$/d'
}

render_chart_images() {
    local release_name="$1"
    shift

    helm template "$release_name" "$@" | extract_workload_images
}

parse_images() {
    local input_path="$1"
    local input_name="${input_path##*/}"

    if [[ -d "$input_path" ]]; then
        if [[ ! -f "$input_path/Chart.yaml" ]]; then
            echo -e "${RED}ERROR: Helm Chart.yaml not found in ${input_path}${NC}" >&2
            return 1
        fi

        render_chart_images "$input_name" "$input_path" --values "$input_path/values.yaml"
        if [[ "$input_name" == 'linkerd' ]]; then
            echo 'cr.l5d.io/linkerd/debug:edge-24.11.8'
        fi
        return
    fi

    yq eval '
        .images
        | to_entries
        | map(select(
            .key != "repo" and
            .key != "imagePullSecrets" and
            .key != "pullPolicy" and
            (.value | type) == "!!map" and
            .value.repo.base != null and
            .value.repo.path != null and
            .value.tag != null
        ))
        | .[]
        | .value.repo.base + "/" + .value.repo.path + ":" + .value.tag
    ' "$input_path"
}

collect_images() {
    local chart_dir

    parse_images "$RAM_VALUES_FILE" || return 1

    for chart_dir in "$HELM_DIR"/*; do
        [[ -d "$chart_dir" && -f "$chart_dir/Chart.yaml" ]] || continue
        [[ "${chart_dir##*/}" == "$RAM_CHART_NAME" ]] && continue
        parse_images "$chart_dir" || return 1
    done
}

mirror_image() {
    local source_image="$1"
    local source_registry="${source_image%%/*}"
    local image_with_tag="${source_image#${source_registry}/}"
    local target_image="${image_with_tag%@*}"
    local import_source="$source_image"
    local import_command target_ref

    if [[ "$source_registry" == 'docker.io' && "$image_with_tag" != */* ]]; then
        import_source="docker.io/library/$image_with_tag"
    fi

    if [[ "$MIRROR_MODE" == 'runtime' ]]; then
        target_ref="${TARGET_REGISTRY}/${target_image}"
        echo -e "${YELLOW}Mirroring: ${source_image}${NC}"
        if "$CONTAINER_RUNTIME" pull "$import_source" &&
            "$CONTAINER_RUNTIME" tag "$import_source" "$target_ref" &&
            "$CONTAINER_RUNTIME" push "$target_ref"; then
            echo -e "${GREEN}Mirrored: ${target_ref}${NC}\n"
            return 0
        fi

        echo -e "${RED}Mirror failed: ${source_image}${NC}\n"
        return 1
    fi

    import_command=(
        az acr import
        --name "$ACR_NAME"
        --source "$import_source"
        --image "$target_image"
        --force
        --only-show-errors
    )

    if [[ "$source_registry" == 'cr.sas.com' ]]; then
        import_command+=(--username "$SAS_USERNAME" --password "$SAS_PASSWORD")
    elif [[ "$source_registry" == 'docker.io' ]]; then
        import_command+=(--username "$DOCKER_USERNAME" --password "$DOCKER_PASSWORD")
    fi

    echo -e "${YELLOW}Importing: ${source_image}${NC}"
    if "${import_command[@]}"; then
        echo -e "${GREEN}Imported: ${ACR_LOGIN_SERVER}/${target_image}${NC}\n"
        return 0
    fi

    echo -e "${RED}Import failed: ${source_image}${NC}\n"
    return 1
}

if ! IMAGE_OUTPUT=$(collect_images); then
    echo -e "${RED}ERROR: Failed to collect images.${NC}"
    exit 1
fi

mapfile -t IMAGES < <(printf '%s\n' "$IMAGE_OUTPUT" | sort -u)

if [ ${#IMAGES[@]} -eq 0 ]; then
    echo -e "${RED}ERROR: No images found.${NC}"
    exit 1
fi

SAS_USERNAME=''
SAS_PASSWORD=''
DOCKER_USERNAME=''
DOCKER_PASSWORD=''

cleanup_credentials() {
    SAS_PASSWORD=''
    DOCKER_PASSWORD=''
    unset SAS_PASSWORD DOCKER_PASSWORD
    if [[ -n "$RUNTIME_AUTH_DIR" ]]; then
        rm -rf "$RUNTIME_AUTH_DIR"
    fi
}

trap cleanup_credentials EXIT

if printf '%s\n' "${IMAGES[@]}" | grep -q '^cr\.sas\.com/'; then
    echo 'Source registry credentials are required for cr.sas.com.'
    read -r -p 'cr.sas.com username from SAS Mirror Manager: ' SAS_USERNAME
    read -r -s -p 'cr.sas.com password from SAS Mirror Manager: ' SAS_PASSWORD
    echo

    if [[ -z "$SAS_USERNAME" || -z "$SAS_PASSWORD" ]]; then
        echo -e "${RED}ERROR: SAS registry credentials are required.${NC}"
        exit 1
    fi
fi

if printf '%s\n' "${IMAGES[@]}" | grep -q '^docker\.io/'; then
    echo 'Source registry credentials are required for docker.io.'
    echo 'Use a Docker Hub personal access token as the password.'
    read -r -p 'Docker Hub username: ' DOCKER_USERNAME
    read -r -s -p 'Docker Hub personal access token: ' DOCKER_PASSWORD
    echo

    if [[ -z "$DOCKER_USERNAME" || -z "$DOCKER_PASSWORD" ]]; then
        echo -e "${RED}ERROR: Docker Hub credentials are required.${NC}"
        exit 1
    fi
fi

if [[ "$MIRROR_MODE" == 'runtime' ]]; then
    RUNTIME_AUTH_DIR=$(mktemp -d)
    if [[ "$CONTAINER_RUNTIME" == 'docker' ]]; then
        DOCKER_CONFIG_SOURCE="${DOCKER_CONFIG:-$HOME/.docker}/config.json"
        if [[ -f "$DOCKER_CONFIG_SOURCE" ]]; then
            cp "$DOCKER_CONFIG_SOURCE" "$RUNTIME_AUTH_DIR/config.json"
        fi
        export DOCKER_CONFIG="$RUNTIME_AUTH_DIR"
    else
        PODMAN_AUTH_SOURCE="${REGISTRY_AUTH_FILE:-${XDG_RUNTIME_DIR:-/run/user/$UID}/containers/auth.json}"
        if [[ -f "$PODMAN_AUTH_SOURCE" ]]; then
            cp "$PODMAN_AUTH_SOURCE" "$RUNTIME_AUTH_DIR/auth.json"
        fi
        export REGISTRY_AUTH_FILE="$RUNTIME_AUTH_DIR/auth.json"
    fi

    if [[ -n "$SAS_USERNAME" ]]; then
        printf '%s' "$SAS_PASSWORD" | "$CONTAINER_RUNTIME" login cr.sas.com \
            --username "$SAS_USERNAME" --password-stdin || exit 1
    fi
    if [[ -n "$DOCKER_USERNAME" ]]; then
        printf '%s' "$DOCKER_PASSWORD" | "$CONTAINER_RUNTIME" login docker.io \
            --username "$DOCKER_USERNAME" --password-stdin || exit 1
    fi
fi

echo -e "${YELLOW}=== Container Image Mirror ===${NC}\n"
echo "Main values:     ${RAM_VALUES_FILE}"
echo "Bundled charts:  ${HELM_DIR}"
echo "Target registry: ${TARGET_REGISTRY}"
echo "Images found:    ${#IMAGES[@]}"
echo ""
echo "Images to mirror:"
for img in "${IMAGES[@]}"; do
    echo "  - $img"
done
echo ""

success_count=0
fail_count=0
failed_images=()

for image in "${IMAGES[@]}"; do
    if mirror_image "$image"; then
        ((success_count++))
    else
        ((fail_count++))
        failed_images+=("$image")
    fi
done

echo -e "${YELLOW}=== Summary ===${NC}"
echo -e "${GREEN}Successful: ${success_count}${NC}"
echo -e "${RED}Failed:     ${fail_count}${NC}"

if [ ${#failed_images[@]} -gt 0 ]; then
    echo -e "\n${RED}Failed images:${NC}"
    for img in "${failed_images[@]}"; do
        echo "  - $img"
    done
fi

if [ $fail_count -eq 0 ]; then
    echo -e "\n${GREEN}All images mirrored successfully!${NC}"
    exit 0
else
    echo -e "\n${YELLOW}Some images failed to mirror. Check the output above for details.${NC}"
    exit 1
fi
