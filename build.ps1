$ErrorActionPreference = 'Stop'

$currentPath = (Split-Path $MyInvocation.MyCommand.Definition)
$nuspecFileRelativePath = Join-Path -Path $currentPath -ChildPath 'multimonitortool.nuspec'
[xml] $nuspec = Get-Content -Path $nuspecFileRelativePath
$version = [Version] $nuspec.package.metadata.version

$global:Latest = @{
    Url32   = 'https://web.archive.org/web/20241104232455if_/https://www.nirsoft.net/utils/multimonitortool.zip'
    Url64   = 'https://web.archive.org/web/20241104232534if_/https://www.nirsoft.net/utils/multimonitortool-x64.zip'
    Version = $version
}

Write-Output 'Downloading...'
Get-RemoteFiles -Purge -NoSuffix

Write-Output 'Creating package...'
choco pack $nuspecFileRelativePath
