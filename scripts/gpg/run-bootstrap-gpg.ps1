# =============================================================================
# run-bootstrap-gpg.ps1  --  Windows (PowerShell) wrapper
#
# Builds (if needed) and runs the bootstrap-gpg container.
# All arguments are passed through to bootstrap-gpg.sh inside the container.
#
# Usage:
#   .\run-bootstrap-gpg.ps1 --release <release>
#
# The kubeconfig at %USERPROFILE%\.kube\config is mounted read-only.
# To use a different kubeconfig, set $env:KUBECONFIG_PATH before running:
#   $env:KUBECONFIG_PATH = "C:\path\to\kubeconfig"
#   .\run-bootstrap-gpg.ps1 ...
# =============================================================================

$ErrorActionPreference = "Stop"

$ImageName = "ram-bootstrap-gpg"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# -- resolve kubeconfig path --------------------------------------------------

if ($env:KUBECONFIG_PATH) {
    $KubeconfigPath = $env:KUBECONFIG_PATH
} else {
    $KubeconfigPath = Join-Path $env:USERPROFILE ".kube\config"
}

# -- build image if not present -----------------------------------------------

# Redirect both stdout and stderr, then check exit code separately
docker image inspect $ImageName > $null 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Image '$ImageName' not found -- building..."
    docker build -t $ImageName $ScriptDir
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Docker build failed."
        exit 1
    }
    Write-Host "Image built."
}

# -- validate kubeconfig ------------------------------------------------------

if (-not (Test-Path $KubeconfigPath)) {
    Write-Error "Kubeconfig not found at: $KubeconfigPath`nSet `$env:KUBECONFIG_PATH to the correct path and re-run."
    exit 1
}

# Docker Desktop on Windows requires Unix-style paths for volume mounts.
# Convert C:\Users\foo\.kube\config  ->  /c/Users/foo/.kube/config
$KubeconfigUnix = $KubeconfigPath -replace '\\', '/'
if ($KubeconfigUnix -match '^([A-Za-z]):(.*)') {
    $KubeconfigUnix = '/' + $Matches[1].ToLower() + $Matches[2]
}

# -- run ----------------------------------------------------------------------

$OutputDir = Join-Path $ScriptDir "output"
New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
$OutputDirUnix = $OutputDir -replace '\\', '/'
if ($OutputDirUnix -match '^([A-Za-z]):(.*)') {
    $OutputDirUnix = '/' + $Matches[1].ToLower() + $Matches[2]
}

docker run --rm -it `
    -v "${KubeconfigUnix}:/root/.kube/config:ro" `
    -v "${OutputDirUnix}:/output" `
    $ImageName `
    @args
