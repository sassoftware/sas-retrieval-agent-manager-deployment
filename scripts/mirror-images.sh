#!/bin/bash

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

usage() {
    echo "Usage: $0 <mirror-registry> <values-yaml>"
    echo "  mirror-registry  Target registry to push images to"
    echo "  values-yaml      Path to Helm values YAML file containing images section"
    echo ""
    echo "Example: $0 my-registry.example.com values.yaml"
    exit 1
}

if [ -z "$1" ] || [ -z "$2" ]; then
    echo -e "${RED}ERROR: Missing required arguments${NC}\n"
    usage
fi

MIRROR_REGISTRY="$1"
VALUES_FILE="$2"

if [ ! -f "$VALUES_FILE" ]; then
    echo -e "${RED}ERROR: Values file not found: ${VALUES_FILE}${NC}"
    exit 1
fi

if ! command -v yq &>/dev/null; then
    echo -e "${RED}ERROR: yq is required but not installed.${NC}"
    echo "Install via: https://github.com/mikefarah/yq"
    exit 1
fi

# Parse images from YAML: for each key under .images (except .repo),
# construct the full source image as base/path:tag
parse_images() {
    local file="$1"

    # Verify the images key exists at all
    local key_count
    key_count=$(yq e '.images | keys | length' "$file" 2>/dev/null)
    if [[ -z "$key_count" || "$key_count" -eq 0 ]]; then
        echo "DEBUG: .images key not found or empty in $file" >&2
        return 1
    fi

    yq e '
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
    ' "$file"
}

mirror_image() {
    local source_image=$1

    # Strip the registry (first component before first /)
    local source_registry
    source_registry=$(echo "$source_image" | cut -d'/' -f1)
    local image_with_tag="${source_image#${source_registry}/}"
    local mirror_image="${MIRROR_REGISTRY}/${image_with_tag}"

    echo -e "${YELLOW}Processing: ${source_image}${NC}"

    echo "  Pulling ${source_image}..."
    if docker pull "$source_image"; then
        echo -e "  ${GREEN}Pull successful${NC}"
    else
        echo -e "  ${RED}Pull failed${NC}"
        return 1
    fi

    echo "  Tagging as ${mirror_image}..."
    if docker tag "$source_image" "$mirror_image"; then
        echo -e "  ${GREEN}Tag successful${NC}"
    else
        echo -e "  ${RED}Tag failed${NC}"
        return 1
    fi

    echo "  Pushing ${mirror_image}..."
    if docker push "$mirror_image"; then
        echo -e "  ${GREEN}Push successful${NC}"
    else
        echo -e "  ${RED}Push failed${NC}"
        return 1
    fi

    echo -e "${GREEN}Successfully mirrored: ${source_image} → ${mirror_image}${NC}\n"
    return 0
}

mapfile -t IMAGES < <(parse_images "$VALUES_FILE")

if [ ${#IMAGES[@]} -eq 0 ]; then
    echo -e "${RED}ERROR: No images found in ${VALUES_FILE}${NC}"
    exit 1
fi

echo -e "${YELLOW}=== Docker Image Mirror Script ===${NC}\n"
echo "Values file:     ${VALUES_FILE}"
echo "Mirror registry: ${MIRROR_REGISTRY}"
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
