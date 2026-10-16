#Requires -Version 7.0
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$EnvFile,
    [string]$Kubeconfig = $(if ($env:KUBECONFIG_PATH) { $env:KUBECONFIG_PATH } else { Join-Path $HOME '.kube/config' }),
    [string]$ImageName = $(if ($env:RAM_VIYA_IMAGE) { $env:RAM_VIYA_IMAGE } else { 'ram-viya-connect:local' }),
    [string]$RamKubeconfig,
    [string]$ViyaKubeconfig
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

foreach ($commandName in @('docker', 'kubectl')) {
    if (-not (Get-Command $commandName -ErrorAction SilentlyContinue)) {
        throw "$commandName is required."
    }
}
$environmentPath = (Resolve-Path -LiteralPath $EnvFile).Path
$contextSettings = @{}
foreach ($line in Get-Content -LiteralPath $environmentPath) {
    $separator = $line.IndexOf('=')
    if ($separator -le 0) { continue }
    $name = $line.Substring(0, $separator)
    if ($name -notin @('KUBE_CONTEXT', 'RAM_KUBE_CONTEXT', 'VIYA_KUBE_CONTEXT')) { continue }
    if ($contextSettings.ContainsKey($name)) { throw "Environment file has more than one $name value." }
    $contextSettings[$name] = $line.Substring($separator + 1)
}
$sharedContext = if ($contextSettings.ContainsKey('KUBE_CONTEXT')) { $contextSettings['KUBE_CONTEXT'] } else { '' }
$ramContext = if ($contextSettings.ContainsKey('RAM_KUBE_CONTEXT')) { $contextSettings['RAM_KUBE_CONTEXT'] } else { '' }
$viyaContext = if ($contextSettings.ContainsKey('VIYA_KUBE_CONTEXT')) { $contextSettings['VIYA_KUBE_CONTEXT'] } else { '' }
if (-not [string]::IsNullOrWhiteSpace($sharedContext)) {
    if (-not [string]::IsNullOrWhiteSpace($ramContext) -or
        -not [string]::IsNullOrWhiteSpace($viyaContext)) {
        throw 'Set KUBE_CONTEXT or the separate RAM and Viya context values, not both.'
    }
    $resolvedRamContext = $sharedContext
    $resolvedViyaContext = $sharedContext
} else {
    if ([string]::IsNullOrWhiteSpace($ramContext) -or
        [string]::IsNullOrWhiteSpace($viyaContext)) {
        throw 'Set KUBE_CONTEXT or both RAM_KUBE_CONTEXT and VIYA_KUBE_CONTEXT in the environment file.'
    }
    $resolvedRamContext = $ramContext
    $resolvedViyaContext = $viyaContext
}
$ramKubeconfigInput = if ($RamKubeconfig) { $RamKubeconfig } else { $Kubeconfig }
$viyaKubeconfigInput = if ($ViyaKubeconfig) { $ViyaKubeconfig } else { $Kubeconfig }
if (-not (Test-Path -LiteralPath $environmentPath -PathType Leaf) -or
    -not (Test-Path -LiteralPath $ramKubeconfigInput -PathType Leaf) -or
    -not (Test-Path -LiteralPath $viyaKubeconfigInput -PathType Leaf)) {
    throw 'Use an existing environment file and Kubernetes configuration file for each cluster.'
}
$ramKubeconfigPath = (Resolve-Path -LiteralPath $ramKubeconfigInput).Path
$viyaKubeconfigPath = (Resolve-Path -LiteralPath $viyaKubeconfigInput).Path
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

    function New-RuntimeKubeconfig {
        param(
            [string]$SelectedContext,
            [string]$SourceKubeconfig,
            [string]$RuntimeConfig
        )
        $rawConfig = & kubectl --kubeconfig $SourceKubeconfig --context $SelectedContext config view --raw --flatten --minify --output json 2>$null
        if ($LASTEXITCODE -ne 0) { throw "Could not read Kubernetes context $SelectedContext." }
        $configuration = ($rawConfig -join "`n") | ConvertFrom-Json -AsHashtable
        if ($configuration.contexts.Count -ne 1 -or $configuration.contexts[0].name -ne $SelectedContext) {
            throw "The Kubernetes configuration does not match context $SelectedContext."
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
                        throw "$commandName is required for Kubernetes context $SelectedContext."
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
        $configuration | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $RuntimeConfig -Encoding utf8NoBOM
    }

    $ramRuntimeConfig = Join-Path $temporaryDirectory 'ram-config.json'
    $viyaRuntimeConfig = Join-Path $temporaryDirectory 'viya-config.json'
    New-RuntimeKubeconfig -SelectedContext $resolvedRamContext `
        -SourceKubeconfig $ramKubeconfigPath -RuntimeConfig $ramRuntimeConfig
    New-RuntimeKubeconfig -SelectedContext $resolvedViyaContext `
        -SourceKubeconfig $viyaKubeconfigPath -RuntimeConfig $viyaRuntimeConfig
    $supportDirectory = Join-Path $PSScriptRoot 'lib'
    & docker build --tag $ImageName --file (Join-Path $supportDirectory 'Dockerfile.viya') $supportDirectory
    if ($LASTEXITCODE -ne 0) { throw 'The Docker image build failed.' }
    $runArguments = @('run', '--rm', '--interactive', '--network', 'host',
        '--volume', "${ramRuntimeConfig}:/root/.kube/ram-config:ro",
        '--volume', "${viyaRuntimeConfig}:/root/.kube/viya-config:ro",
        '--env-file', $environmentPath,
        '--env', "RAM_KUBE_CONTEXT=$resolvedRamContext",
        '--env', "VIYA_KUBE_CONTEXT=$resolvedViyaContext",
        '--env', 'RAM_KUBECONFIG=/root/.kube/ram-config',
        '--env', 'VIYA_KUBECONFIG=/root/.kube/viya-config', $ImageName)
    & docker @runArguments
    if ($LASTEXITCODE -ne 0) { throw 'The Viya connection container failed. Stop and check the reported stage.' }
} finally {
    if (Test-Path -LiteralPath $temporaryDirectory) {
        Remove-Item -LiteralPath $temporaryDirectory -Recurse -Force
    }
}