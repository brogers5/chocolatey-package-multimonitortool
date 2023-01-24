$ErrorActionPreference = 'Stop'

$archiveFileNames = @('multimonitortool-x64.zip', 'multimonitortool.zip')

if ((Get-OSArchitectureWidth -Compare 64) -and ($env:chocolateyForceX86 -ne $true))
{
  $extractedArchiveName = $archiveFileNames[0]
}
else
{
  $extractedArchiveName = $archiveFileNames[1]
}
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$extractedArchivePath = Join-Path -Path $toolsDir -ChildPath $extractedArchiveName

$packageArgs = @{
  fileFullPath   = $extractedArchivePath
  destination    = $toolsDir
  packageName    = $env:ChocolateyPackageName
}
Get-ChocolateyUnzip @packageArgs

#Clean up ZIP archives post-extraction to prevent unnecessary disk bloat
foreach ($archiveFileName in $archiveFileNames)
{
  $archiveFilePath = Join-Path -Path $toolsDir -ChildPath $archiveFileName
  Remove-Item -Path $archiveFilePath -Force -ErrorAction SilentlyContinue
}

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
