$ErrorActionPreference = 'Stop'

$packageName = 'multimonitortool'
$url = 'http://www.nirsoft.net/utils/multimonitortool.zip'
$checksum = '5c448b256a11c6e2280b05626ebe8cc9fa67307895d0121260e8b3f379b98fe2'
$checksumType = 'sha256'
$url64 = 'http://www.nirsoft.net/utils/multimonitortool-x64.zip'
$checksum64 = '128949125987ba5264d7e99f6baa50d2c0a500e88c22c62101db0210da1cba4e'
$checksumType64 = 'sha256'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$installFile = Join-Path $toolsDir "$($packageName).exe"

Install-ChocolateyZipPackage -PackageName "$packageName" `
                             -Url "$url" `
                             -UnzipLocation "$toolsDir" `
                             -Url64bit "$url64" `
                             -Checksum "$checksum" `
                             -ChecksumType "$checksumType" `
                             -Checksum64 "$checksum64" `
                             -ChecksumType64 "$checksumType64"

Set-Content -Path ("$installFile.gui") `
            -Value $null