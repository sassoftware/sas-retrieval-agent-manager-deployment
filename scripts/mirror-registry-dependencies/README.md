# Mirror Registry Dependency Script

This script will populate the given registry with the images that RAM is dependent on that are not included in the installation by default.

Running this script will:

1) Pull each docker image listed at the top of the script

2) Tag each docker image with <your.registry.example.com>/<individual_docker_image>:<individual_docker_image_tag>

3) Push each docker image to your mirror registry

To use the script:

```sh

./mirror_images.sh <your.registry.example.com>

```
