$ErrorActionPreference = 'Stop'

$packageName = 'multimonitortool'
$url = 'https://www.nirsoft.net/utils/multimonitortool.zip'
$checksum = '400837d4e6cba4bf4e3292bfa74b245107cbe40f10c138be5dde67c5e1431ec5'
$checksumType = 'sha256'
$url64 = 'https://www.nirsoft.net/utils/multimonitortool-x64.zip'
$checksum64 = '2cf23f292ed38c946a8c7e1b904f89d3f6af9d3a5ecb43cef681bb07a3702715'
$checksumType64 = 'sha256'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

Install-ChocolateyZipPackage -PackageName "$packageName" `
                             -Url "$url" `
                             -UnzipLocation "$toolsDir" `
                             -Url64bit "$url64" `
                             -Checksum "$checksum" `
                             -ChecksumType "$checksumType" `
                             -Checksum64 "$checksum64" `
                             -ChecksumType64 "$checksumType64"

$softwareName = 'MultiMonitorTool'
$binaryFileName = "$softwareName.exe"
$linkName = "$softwareName.lnk"
$targetPath = Join-Path -Path $toolsDir -ChildPath $binaryFileName

$pp = Get-PackageParameters
if ($pp.NoShim)
{
    #Create shim ignore file
    $ignoreFilePath = Join-Path -Path $toolsDir -ChildPath "$binaryFileName.ignore"
    Set-Content -Path $ignoreFilePath -Value $null -ErrorAction SilentlyContinue
}
else
{
    #Create GUI shim
    $guiShimPath = Join-Path -Path $toolsDir -ChildPath "$binaryFileName.gui"
    Set-Content -Path $guiShimPath -Value $null -ErrorAction SilentlyContinue
}

if (!$pp.NoDesktopShortcut)
{
    $desktopDirectory = [Environment]::GetFolderPath([Environment+SpecialFolder]::DesktopDirectory)
    $shortcutFilePath = Join-Path -Path $desktopDirectory -ChildPath $linkName
    Install-ChocolateyShortcut -ShortcutFilePath $shortcutFilePath -TargetPath $targetPath -ErrorAction SilentlyContinue
}

if (!$pp.NoProgramsShortcut)
{
    $programsDirectory = [Environment]::GetFolderPath([Environment+SpecialFolder]::Programs)
    $shortcutFilePath = Join-Path -Path $programsDirectory -ChildPath $linkName
    Install-ChocolateyShortcut -ShortcutFilePath $shortcutFilePath -TargetPath $targetPath -ErrorAction SilentlyContinue
}

if ($pp.Start)
{
  try
  {
    Start-Process -FilePath $targetPath -ErrorAction Continue
  }
  catch
  {
    Write-Warning "$softwareName failed to start, please try to manually start it instead."
  }
}
