$ErrorActionPreference = "Stop"

$ImageName = "ram-connect-viya"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RebuildImage = $env:RAM_CONNECT_VIYA_REBUILD -eq "true"

if ($env:KUBECONFIG_PATH) {
    $KubeconfigPath = $env:KUBECONFIG_PATH
} else {
    $KubeconfigPath = Join-Path $env:USERPROFILE ".kube\config"
}

function Convert-ToDockerPath {
    param([Parameter(Mandatory = $true)][string]$Path)

    $ResolvedPath = (Resolve-Path $Path).Path -replace '\\', '/'
    if ($ResolvedPath -match '^([A-Za-z]):(.*)') {
        return '/' + $Matches[1].ToLower() + $Matches[2]
    }
    return $ResolvedPath
}

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Error "Docker is required."
    exit 1
}

& docker info *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Error "Docker is not available. Start Docker and run the command again."
    exit 1
}

if (-not (Test-Path -PathType Leaf $KubeconfigPath)) {
    Write-Error "Kubernetes configuration file not found: $KubeconfigPath`nSet `$env:KUBECONFIG_PATH to the correct absolute path."
    exit 1
}

$KubeconfigDockerPath = Convert-ToDockerPath $KubeconfigPath
$ContainerArgs = [System.Collections.Generic.List[string]]::new()
$DockerArgs = [System.Collections.Generic.List[string]]::new()
$DockerArgs.Add("run")
$DockerArgs.Add("--rm")
$DockerArgs.Add("--interactive")
$DockerArgs.Add("--tty")
$DockerArgs.Add("--volume")
$DockerArgs.Add("${KubeconfigDockerPath}:/root/.kube/config:ro")

for ($Index = 0; $Index -lt $args.Count; $Index++) {
    if ($args[$Index] -eq "--ca-file") {
        $Index++
        if ($Index -ge $args.Count -or -not $args[$Index]) {
            Write-Error "--ca-file requires a value."
            exit 1
        }
        $CaPath = $args[$Index]
        if (-not (Test-Path -PathType Leaf $CaPath)) {
            Write-Error "CA certificate file not found: $CaPath"
            exit 1
        }
        $CaDockerPath = Convert-ToDockerPath $CaPath
        $DockerArgs.Add("--volume")
        $DockerArgs.Add("${CaDockerPath}:/opt/ram-connect-viya-ca/ca.crt:ro")
        $ContainerArgs.Add("--ca-file")
        $ContainerArgs.Add("/opt/ram-connect-viya-ca/ca.crt")
    } else {
        $ContainerArgs.Add($args[$Index])
    }
}

& docker image inspect $ImageName *> $null
if ($RebuildImage -or $LASTEXITCODE -ne 0) {
    & docker build --tag $ImageName $ScriptDir
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Docker image build failed."
        exit 1
    }
}

$DockerArgs.Add($ImageName)
foreach ($Argument in $ContainerArgs) {
    $DockerArgs.Add($Argument)
}

& docker @DockerArgs
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}
