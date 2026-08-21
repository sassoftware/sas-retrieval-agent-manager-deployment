$ErrorActionPreference = "Stop"

$ImageName = "ram-mirror-images"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepositoryRoot = (Resolve-Path (Join-Path $ScriptDir "../..")).Path

if ($args.Count -ne 1) {
    Write-Error "Usage: $($MyInvocation.MyCommand.Name) <target-registry>"
    exit 1
}

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Error "Docker is required but is not installed."
    exit 1
}

Write-Host "Building '$ImageName' with the current mirror-images.sh."
docker build --tag $ImageName $ScriptDir
if ($LASTEXITCODE -ne 0) {
    Write-Error "Docker build failed."
    exit 1
}

$HelmDir = Join-Path $RepositoryRoot "helm"
$DockerArgs = @(
    "run",
    "--rm",
    "-it",
    "--mount", "type=bind,source=$HelmDir,target=/workspace/helm,readonly",
    "--mount", "type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock"
)

if ($env:DOCKER_CONFIG) {
    $DockerConfigDir = $env:DOCKER_CONFIG
} else {
    $DockerConfigDir = Join-Path $HOME ".docker"
}
$DockerConfigFile = Join-Path $DockerConfigDir "config.json"
if (Test-Path $DockerConfigFile -PathType Leaf) {
    $DockerArgs += "--mount"
    $DockerArgs += "type=bind,source=$DockerConfigFile,target=/root/.docker/config.json,readonly"
}

if ($env:AZURE_CONFIG_DIR) {
    $AzureConfigDir = $env:AZURE_CONFIG_DIR
} else {
    $AzureConfigDir = Join-Path $HOME ".azure"
}
if (Test-Path $AzureConfigDir -PathType Container) {
    $DockerArgs += "--mount"
    $DockerArgs += "type=bind,source=$AzureConfigDir,target=/root/.azure"
}

$DockerArgs += $ImageName
$DockerArgs += $args
docker @DockerArgs
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}