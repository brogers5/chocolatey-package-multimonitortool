$ErrorActionPreference = 'Stop'

$currentPath = (Split-Path $MyInvocation.MyCommand.Definition)
$nuspecFileRelativePath = Join-Path -Path $currentPath -ChildPath 'multimonitortool.nuspec'
[xml] $nuspec = Get-Content -Path $nuspecFileRelativePath
$version = [Version] $nuspec.package.metadata.version

$global:Latest = @{
    Url32 = 'https://web.archive.org/web/20230221040619if_/https://www.nirsoft.net/utils/multimonitortool.zip'
    Url64 = 'https://web.archive.org/web/20230221040641if_/https://www.nirsoft.net/utils/multimonitortool-x64.zip'
    Version = $version
}

Write-Host 'Downloading...'
Get-RemoteFiles -Purge -NoSuffix

Write-Host 'Creating package...'
choco pack $nuspecFileRelativePath
