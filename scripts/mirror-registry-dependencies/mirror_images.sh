#!/bin/bash

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Array of images to mirror
IMAGES=(
    "docker.io/postgres:15-alpine"
    "docker.io/alpine/k8s:1.31.12"
    "docker.io/filebrowser/filebrowser:v2-s6"
    "docker.io/postgrest/postgrest:v13.0.4"
    "docker.io/swaggerapi/swagger-ui:v5.17.14"
    "docker.io/boky/postfix:latest"
    "docker.io/vladgh/gpg:1.3.6"
    "quay.io/oauth2-proxy/oauth2-proxy:v7.12.0"
)

# Check if registry argument is provided
if [ -z "$1" ]; then
    echo -e "${RED}ERROR: Mirror registry not specified${NC}\n"
    usage
fi

MIRROR_REGISTRY="$1"

# Function to pull, tag, and push an image
mirror_image() {
    local source_image=$1
    
    # Extract registry from source image
    local source_registry=$(echo "$source_image" | cut -d'/' -f1)
    
    # Extract image name without registry
    local image_name=$(echo "$source_image" | sed 's|^[^/]*/||')

    # Remove registry prefix to get image:tag
    local image_with_tag="${source_image#${source_registry}/}"
    
    # Construct mirror image name (preserving full path and tag)
    local mirror_image="${MIRROR_REGISTRY}/${image_with_tag}"
    
    echo -e "${YELLOW}Processing: ${source_image}${NC}"
    
    # Pull image
    echo "  Pulling ${source_image}..."
    if docker pull "$source_image"; then
        echo -e "  ${GREEN}Pull successful${NC}"
    else
        echo -e "  ${RED}Pull failed${NC}"
        return 1
    fi
    
    # Tag image
    echo "  Tagging as ${mirror_image}..."
    if docker tag "$source_image" "$mirror_image"; then
        echo -e "  ${GREEN}Tag successful${NC}"
    else
        echo -e "  ${RED}Tag failed${NC}"
        return 1
    fi
    
    # Push image
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

echo -e "${YELLOW}=== Docker Image Mirror Script ===${NC}\n"
echo "Mirror Registry: ${MIRROR_REGISTRY}"
echo "Total images to mirror: ${#IMAGES[@]}"
echo ""

# Check if mirror registry is configured
if [ "$MIRROR_REGISTRY" = "your-registry.example.com" ]; then
    echo -e "${RED}ERROR: Please configure MIRROR_REGISTRY variable at the top of the script${NC}"
    exit 1
fi

success_count=0
fail_count=0
for image in "${IMAGES[@]}"; do
    if mirror_image "$image"; then
        ((success_count++))
    else
        ((fail_count++))
    fi
done

# Summary
echo -e "${YELLOW}=== Summary ===${NC}"
echo -e "${GREEN}Successful: ${success_count}${NC}"
echo -e "${RED}Failed: ${fail_count}${NC}"

if [ $fail_count -eq 0 ]; then
    echo -e "\n${GREEN}All images mirrored successfully!${NC}"
    exit 0
else
    echo -e "\n${YELLOW}Some images failed to mirror. Check the output above for details.${NC}"
    exit 1
fi