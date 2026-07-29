# =============================================================================
# run-initialize-db.ps1 - Windows (PowerShell) wrapper
#
# Builds (if needed) and runs the database initialization container. Variables
# already set in the host environment are passed through to the container.
# Credential values are not written into the Docker command line.
#
# Usage:
#   $env:DB_HOST = "postgres.example.com"
#   $env:DB_ADMIN_PASSWORD = "enter-this-locally"
#   .\run-initialize-db.ps1
#
# Set $env:ENABLE_VECTOR_STORE = "false" to skip vector-store initialization.
# Additional arguments are passed to initialize-db.sh inside the container.
# =============================================================================

$ErrorActionPreference = "Stop"

$ImageName = "ram-initialize-db"
$ImageVersion = "2"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

$ExistingImageVersion = docker image inspect --format '{{ index .Config.Labels "ram.initialize-db.version" }}' $ImageName 2>$null
if ($LASTEXITCODE -ne 0 -or $ExistingImageVersion -ne $ImageVersion) {
    Write-Host "Image '$ImageName' is missing or outdated -- building..."
    docker build --label "ram.initialize-db.version=$ImageVersion" -t $ImageName $ScriptDir
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Docker build failed."
        exit 1
    }
    Write-Host "Image built."
}

$Variables = @(
    "DB_HOST", "DB_PORT", "DB_SSL_MODE", "DB_ADMIN_USER", "DB_ADMIN_PASSWORD",
    "POSTGREST_USER", "POSTGREST_PASSWORD", "MIGRATION_USER", "MIGRATION_PASSWORD",
    "VECTORIZATION_USER", "VECTORIZATION_PASSWORD", "EMBEDDING_USER", "EMBEDDING_PASSWORD",
    "MONITORING_USER", "MONITORING_PASSWORD", "OTEL_USER", "OTEL_PASSWORD",
    "KEYCLOAK_USER", "KEYCLOAK_PASSWORD", "VECTOR_STORE_USER", "VECTOR_STORE_PASSWORD",
    "APPLICATION_DB", "APPLICATION_SCHEMA", "MONITORING_DB", "MONITORING_SCHEMA",
    "KEYCLOAK_DB", "KEYCLOAK_SCHEMA", "VECTOR_STORE_DB", "VECTOR_STORE_SCHEMA",
    "APPLICATION_USER_ROLE", "APPLICATION_ADMIN_ROLE", "MONITORING_USER_ROLE",
    "MONITORING_ADMIN_ROLE", "ENABLE_VECTOR_STORE"
)

$DockerArgs = @("run", "--rm")
foreach ($Variable in $Variables) {
    $Value = [Environment]::GetEnvironmentVariable($Variable)
    if ($null -ne $Value) {
        $DockerArgs += "--env"
        $DockerArgs += $Variable
    }
}

$DockerArgs += $ImageName
$DockerArgs += $args
docker @DockerArgs
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}
