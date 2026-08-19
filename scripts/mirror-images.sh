#!/usr/bin/env bash

set -u -o pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

KUEUE_VERSION='0.17.2'
NGINX_VERSION='4.12.3'
CONTOUR_CHART_VERSION='0.2.1'

usage() {
    echo "Usage: $0 <acr-name-or-login-server> <values-file-or-helm-chart>"
    echo
    echo "Import images into Azure Container Registry (ACR) with az acr import."
    echo "The script renders Helm charts to find active workload images."
    echo "Run the script from the repository root."
    echo
    echo "Arguments:"
    echo "  acr-name-or-login-server  ACR name or login server"
    echo "  values-file-or-helm-chart Local chart directory or supported values file"
    echo
    echo "Prerequisites:"
    echo "  - Sign in with az login."
    echo "  - Install Azure CLI, Helm, and mikefarah yq v4 or later."
    echo "  - Use an identity that can import images into the target ACR."
    echo "  - Have source credentials for cr.sas.com and docker.io when requested."
    echo
    echo "Local chart examples:"
    echo "  $0 ramnoint1cr.azurecr.io ./helm/cert-manager"
    echo "  $0 ramnoint1cr.azurecr.io ./helm/trust-manager"
    echo "  $0 ramnoint1cr.azurecr.io ./helm/linkerd"
    echo
    echo "RAM values example:"
    echo "  $0 ramnoint1cr.azurecr.io ./helm/sas-retrieval-agent-manager/values.yaml"
    echo
    echo "External chart examples:"
    echo "  $0 ramnoint1cr.azurecr.io ./examples/dependencies/required/kueue.yaml"
    echo "  $0 ramnoint1cr.azurecr.io ./examples/dependencies/required/ingress-controllers/nginx.yaml"
    echo "  $0 ramnoint1cr.azurecr.io ./examples/dependencies/required/ingress-controllers/contour.yaml"
    echo
    echo "External chart versions:"
    echo "  Kueue:  $KUEUE_VERSION"
    echo "  NGINX:  $NGINX_VERSION"
    echo "  Contour chart: $CONTOUR_CHART_VERSION"
    exit 1
}

if [[ $# -ne 2 ]]; then
    echo -e "${RED}ERROR: Missing required arguments${NC}\n"
    usage
fi

for command_name in az helm yq; do
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
ACR_NAME="${TARGET_REGISTRY%%.*}"
INPUT_PATH="${2%/}"

if [[ ! -f "$INPUT_PATH" && ! -d "$INPUT_PATH" ]]; then
    echo -e "${RED}ERROR: Input not found: ${INPUT_PATH}${NC}"
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

    case "$input_name" in
        kueue.yaml)
            render_chart_images kueue oci://registry.k8s.io/kueue/charts/kueue \
                --version "$KUEUE_VERSION" --values "$input_path"
            return
            ;;
        nginx.yaml)
            render_chart_images nginx-ingress-nginx-controller ingress-nginx \
                --repo https://kubernetes.github.io/ingress-nginx \
                --version "$NGINX_VERSION" --values "$input_path"
            return
            ;;
        contour.yaml)
            render_chart_images contour contour \
                --repo https://projectcontour.github.io/helm-charts \
                --version "$CONTOUR_CHART_VERSION" --values "$input_path"
            return
            ;;
    esac

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

mirror_image() {
    local source_image="$1"
    local source_registry="${source_image%%/*}"
    local image_with_tag="${source_image#${source_registry}/}"
    local target_image="${image_with_tag%@*}"
    local import_source="$source_image"
    local import_command

    if [[ "$source_registry" == 'docker.io' && "$image_with_tag" != */* ]]; then
        import_source="docker.io/library/$image_with_tag"
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

mapfile -t IMAGES < <(parse_images "$INPUT_PATH" | sort -u)

if [ ${#IMAGES[@]} -eq 0 ]; then
    echo -e "${RED}ERROR: No workload images found in ${INPUT_PATH}${NC}"
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

echo -e "${YELLOW}=== ACR Image Import ===${NC}\n"
echo "Input:           ${INPUT_PATH}"
echo "Target registry: ${ACR_LOGIN_SERVER}"
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
