# Mirror Container Images

Use the mirror container to copy all required SAS Retrieval Agent Manager images to one target container registry.

The script reads all image entries from:

- `helm/sas-retrieval-agent-manager/values.yaml`
- Each bundled Helm chart under `helm`

The script renders the bundled charts and removes duplicate image references. It keeps the repository path after the source registry name. For example:

```text
quay.io/jetstack/trust-manager:v0.18.0
```

becomes:

```text
<target-registry>/jetstack/trust-manager:v0.18.0
```

## Prerequisites

Install Docker. Start the Docker service before you run the launcher.

For Azure Container Registry (ACR), install Azure CLI on the host. Sign in with an identity that can import images:

```bash
az login
```

For another Open Container Initiative (OCI) registry, sign in to the target registry:

```bash
docker login <target-registry>
```

The target account must have permission to push images.

Get these source credentials:

- A user name and password for `cr.sas.com` from SAS Mirror Manager
- A Docker Hub user name and personal access token

The container includes Bash, Helm, `yq`, Docker CLI, and Azure CLI. The launcher mounts the host Docker socket and configuration. It also mounts the host Azure configuration when that directory exists.

The Bash script requests source credentials only when the image set uses the applicable source registry. It stores runtime credentials in a temporary configuration. It removes that configuration when the command ends.

## Run the Script

Change to the mirror directory:

```bash
cd scripts/mirror
```

On Linux or macOS, run:

```bash
./run-mirror-images.sh <target-registry>
```

On Windows PowerShell, run:

```powershell
.\run-mirror-images.ps1 <target-registry>
```

The launcher builds the `ram-mirror-images` image from the current mirror folder on each run. The Dockerfile copies the current `mirror-images.sh` into the image and uses it as the container entrypoint. Docker uses its build cache when the files did not change.

## ACR Example

Pass the ACR login server:

```bash
./run-mirror-images.sh ramnoint1cr.azurecr.io
```

You can also pass the ACR name:

```bash
./run-mirror-images.sh ramnoint1cr
```

The script uses `az acr import` for ACR. The machine does not need network access to a private ACR endpoint.

On Windows PowerShell, replace `./run-mirror-images.sh` with `.\run-mirror-images.ps1`.

## Other Registry Example

```bash
./run-mirror-images.sh registry.example.com
```

For a registry with a port, include the port:

```bash
./run-mirror-images.sh localhost:5000
```

The script uses Docker or Podman to pull each source image, add the target name, and push the image.

## Result

The command shows the source images, target registry, success count, and failure count. It returns a nonzero exit code when one or more images fail.

Set the image registry in your deployment values to the same target registry after all images are copied:

```yaml
images:
  repo:
    base: registry.example.com
```

## Common Errors

`Sign in to Azure with az login.`

Run `az login`. Confirm that the selected identity can import images into the target ACR.

`Docker is required but is not installed.`

Install Docker. Start the Docker service. Then run the launcher again.

`SAS registry credentials are required.`

Get valid `cr.sas.com` credentials from SAS Mirror Manager. Enter both values when the script requests them.

`Docker Hub credentials are required.`

Enter a Docker Hub user name. Use a personal access token as the password.

`Failed to collect images.`

Confirm that the repository contains the main values file and the bundled Helm charts. Rebuild the container if the error continues.
