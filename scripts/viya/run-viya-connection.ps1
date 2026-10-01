#Requires -Version 7.0
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$Context,
    [Parameter(Mandatory = $true)][string]$EnvFile,
    [string]$Kubeconfig = $(if ($env:KUBECONFIG_PATH) { $env:KUBECONFIG_PATH } else { Join-Path $HOME '.kube/config' }),
    [string]$ImageName = $(if ($env:RAM_VIYA_IMAGE) { $env:RAM_VIYA_IMAGE } else { 'ram-viya-connect:local' })
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

foreach ($commandName in @('docker', 'kubectl')) {
    if (-not (Get-Command $commandName -ErrorAction SilentlyContinue)) {
        throw "$commandName is required."
    }
}
$environmentPath = (Resolve-Path -LiteralPath $EnvFile).Path
$kubeconfigPath = (Resolve-Path -LiteralPath $Kubeconfig).Path
if (-not (Test-Path -LiteralPath $environmentPath -PathType Leaf) -or
    -not (Test-Path -LiteralPath $kubeconfigPath -PathType Leaf)) {
    throw 'Use an existing environment file and Kubernetes configuration file.'
}
& docker info *> $null
if ($LASTEXITCODE -ne 0) { throw 'Docker is not available.' }

$temporaryDirectory = Join-Path ([System.IO.Path]::GetTempPath()) ('ram-viya-' + [guid]::NewGuid())
try {
    $null = New-Item -ItemType Directory -Path $temporaryDirectory
    if ($IsWindows) {
        $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent().User
        $access = [System.Security.AccessControl.DirectorySecurity]::new()
        $access.SetAccessRuleProtection($true, $false)
        $access.SetOwner($identity)
        $rule = [System.Security.AccessControl.FileSystemAccessRule]::new(
            $identity, 'FullControl', 'ContainerInherit,ObjectInherit', 'None', 'Allow')
        $access.AddAccessRule($rule)
        Set-Acl -LiteralPath $temporaryDirectory -AclObject $access
    } else {
        & chmod 700 $temporaryDirectory
        if ($LASTEXITCODE -ne 0) { throw 'Could not protect the temporary directory.' }
    }

    $rawConfig = & kubectl --kubeconfig $kubeconfigPath --context $Context config view --raw --flatten --minify --output json 2>$null
    if ($LASTEXITCODE -ne 0) { throw 'Could not read the selected Kubernetes context.' }
    $configuration = ($rawConfig -join "`n") | ConvertFrom-Json -AsHashtable
    if ($configuration.contexts.Count -ne 1 -or $configuration.contexts[0].name -ne $Context) {
        throw 'The Kubernetes configuration does not match the selected context.'
    }
    $user = $configuration.users[0].user
    if ($user.ContainsKey('exec')) {
        $execCommand = [System.IO.Path]::GetFileNameWithoutExtension($user.exec.command)
        if ($execCommand -ne 'kubelogin') {
            throw 'The container supports only kubelogin for Kubernetes exec authentication.'
        }
        $loginArgs = @($user.exec.args)
        $loginIndex = [Array]::IndexOf($loginArgs, '--login')
        if ($loginIndex -ge 0 -and $loginIndex + 1 -lt $loginArgs.Count -and
            $loginArgs[$loginIndex + 1] -eq 'azurecli') {
            foreach ($commandName in @('az', 'kubelogin')) {
                if (-not (Get-Command $commandName -ErrorAction SilentlyContinue)) {
                    throw "$commandName is required for this Kubernetes context."
                }
            }
            $tokenResponse = & kubelogin @loginArgs 2>$null
            if ($LASTEXITCODE -ne 0) { throw 'Could not get the Kubernetes access token.' }
            $credential = ($tokenResponse -join "`n") | ConvertFrom-Json -AsHashtable
            if (-not $credential.status.token) { throw 'The Kubernetes access token is empty.' }
            $user.Remove('exec')
            $user.Remove('auth-provider')
            $user.token = $credential.status.token
        } else {
            $user.exec.command = 'kubelogin'
        }
    }
    $runtimeConfig = Join-Path $temporaryDirectory 'config.json'
    $configuration | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $runtimeConfig -Encoding utf8NoBOM
    $supportDirectory = Join-Path $PSScriptRoot 'lib'
    & docker build --tag $ImageName --file (Join-Path $supportDirectory 'Dockerfile.viya') $supportDirectory
    if ($LASTEXITCODE -ne 0) { throw 'The Docker image build failed.' }
    $runArguments = @('run', '--rm', '--interactive', '--network', 'host',
        '--volume', "${runtimeConfig}:/root/.kube/config:ro",
        '--env-file', $environmentPath, '--env', "KUBE_CONTEXT=$Context", $ImageName)
    & docker @runArguments
    if ($LASTEXITCODE -ne 0) { throw 'The Viya connection container failed. Stop and check the reported stage.' }
} finally {
    if (Test-Path -LiteralPath $temporaryDirectory) {
        Remove-Item -LiteralPath $temporaryDirectory -Recurse -Force
    }
    $rawConfig = $null
    $configuration = $null
    $tokenResponse = $null
    $credential = $null
}