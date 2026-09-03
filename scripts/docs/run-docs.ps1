# Starts the RAM documentation site locally with the same Ruby version as GitHub Pages.
# Usage: .\scripts\docs\run-docs.ps1

[CmdletBinding()]
param(
    [ValidateRange(1, 65535)]
    [int]$Port = 4000
)

$ErrorActionPreference = "Stop"
$ImageName = "ruby:3.3"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepositoryPath = (Resolve-Path (Join-Path $ScriptDir "..\..")).Path

function Get-AvailablePort {
    param([int]$StartingPort)

    $CandidatePort = $StartingPort
    while (Get-NetTCPConnection -State Listen -LocalPort $CandidatePort -ErrorAction SilentlyContinue) {
        $CandidatePort++
    }

    return $CandidatePort
}

docker image inspect $ImageName *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Downloading Docker image '$ImageName'..."
    docker pull $ImageName
    if ($LASTEXITCODE -ne 0) {
        throw "Could not download Docker image '$ImageName'."
    }
}

$SitePort = Get-AvailablePort -StartingPort $Port
$LiveReloadPort = Get-AvailablePort -StartingPort 35729

Write-Host "Starting the documentation site at http://localhost:$SitePort"
Write-Host "Use Ctrl+C to stop the local server."

docker run --rm -it `
    -p "${SitePort}:4000" `
    -p "${LiveReloadPort}:${LiveReloadPort}" `
    -v "${RepositoryPath}:/site" `
    -w /site `
    $ImageName `
    bash -lc "gem install jekyll -v '~> 4.3' --no-document && gem install just-the-docs -v '~> 0.10.1' --no-document && gem install jekyll-relative-links -v '~> 0.7.0' --no-document && /usr/local/bundle/bin/jekyll serve --host 0.0.0.0 --port 4000 --livereload --livereload-port $LiveReloadPort --force_polling --baseurl ''"