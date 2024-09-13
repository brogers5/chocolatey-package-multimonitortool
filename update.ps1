Import-Module au

$currentPath = (Split-Path $MyInvocation.MyCommand.Definition)
$toolsPath = Join-Path -Path $currentPath -ChildPath 'tools'

$projectUri = 'https://www.nirsoft.net/utils/multi_monitor_tool.html'
$checksumsUrl = 'https://www.nirsoft.net/hash_check/?software=multimonitortool'
$userAgent = 'Update checker of Chocolatey Community Package ''multimonitortool'''

function Add-ArchivedUrls {
    $seleniumModuleName = 'Selenium'
    if (!(Get-Module -ListAvailable -Name $seleniumModuleName)) {
        Install-Module -Name $seleniumModuleName -AllowPrerelease
    }
    Import-Module $seleniumModuleName

    if (!(Test-Path -Path "$env:PROGRAMFILES\Mozilla Firefox\firefox.exe")) {
        choco install firefox -y
    }

    $checksumsArchiveUrl = "https://web.archive.org/save/$checksumsUrl"
    Write-Output "Starting Selenium at $checksumsArchiveUrl"
    $seleniumDriver = Start-SeFirefox -StartURL $checksumsArchiveUrl -Headless
    $Latest.ArchivedChecksumsURL = $seleniumDriver.Url
    $seleniumDriver.Dispose()

    $downloadUrl = "https://web.archive.org/save/$($Latest.Url32)"
    Write-Output "Starting Selenium at $downloadUrl"
    $seleniumDriver = Start-SeFirefox $downloadUrl -Headless
    $Latest.ArchivedDownloadURL32 = $seleniumDriver.Url
    $Latest.DirectArchivedDownloadURL32 = $Latest.ArchivedDownloadURL32 -replace '(\d{14})/', "`$1if_/"
    $seleniumDriver.Dispose()

    $downloadUrl = "https://web.archive.org/save/$($Latest.Url64)"
    Write-Output "Starting Selenium at $downloadUrl"
    $seleniumDriver = Start-SeFirefox $downloadUrl -Headless
    $Latest.ArchivedDownloadURL64 = $seleniumDriver.Url
    $Latest.DirectArchivedDownloadURL64 = $Latest.ArchivedDownloadURL64 -replace '(\d{14})/', "`$1if_/"
    $seleniumDriver.Dispose()
}

function Read-ExpectedChecksums {
    $checksumsResponse = Invoke-WebRequest -Uri $checksumsUrl -UserAgent $userAgent -UseBasicParsing

    $Latest.Expected32ChecksumMD5 = [Regex]::Matches($checksumsResponse.Content, '\b[a-f0-9]{32}\b').Groups[0].Value
    $Latest.Expected32ChecksumSHA1 = [Regex]::Matches($checksumsResponse.Content, '\b[a-f0-9]{40}\b').Groups[0].Value
    $Latest.Expected32ChecksumSHA256 = [Regex]::Matches($checksumsResponse.Content, '\b[a-f0-9]{64}\b').Groups[0].Value
    $Latest.Expected32ChecksumSHA512 = [Regex]::Matches($checksumsResponse.Content, '\b[a-f0-9]{128}\b').Groups[0].Value

    $Latest.Expected64ChecksumMD5 = [Regex]::Matches($checksumsResponse.Content, '\b[a-f0-9]{32}\b').Groups[2].Value
    $Latest.Expected64ChecksumSHA1 = [Regex]::Matches($checksumsResponse.Content, '\b[a-f0-9]{40}\b').Groups[2].Value
    $Latest.Expected64ChecksumSHA256 = [Regex]::Matches($checksumsResponse.Content, '\b[a-f0-9]{64}\b').Groups[2].Value
    $Latest.Expected64ChecksumSHA512 = [Regex]::Matches($checksumsResponse.Content, '\b[a-f0-9]{128}\b').Groups[2].Value
}

function Confirm-Checksum($FilePath, $Algorithm, $ExpectedHash) {
    $hash = (Get-FileHash -Path $FilePath -Algorithm $Algorithm).Hash
    if ($ExpectedHash -ne $hash) {
        throw "$Algorithm checksum mismatch! Expected '$ExpectedHash', actual is '$hash'"
    }
}

function Confirm-Checksums {
    $filePath32 = Join-Path -Path $toolsPath -ChildPath $Latest.FileName32
    $filePath64 = Join-Path -Path $toolsPath -ChildPath $Latest.FileName64

    Confirm-Checksum -FilePath $filePath32 -Algorithm 'MD5' -ExpectedHash $Latest.Expected32ChecksumMD5
    Confirm-Checksum -FilePath $filePath32 -Algorithm 'SHA1' -ExpectedHash $Latest.Expected32ChecksumSHA1
    Confirm-Checksum -FilePath $filePath32 -Algorithm 'SHA256' -ExpectedHash $Latest.Expected32ChecksumSHA256
    Confirm-Checksum -FilePath $filePath32 -Algorithm 'SHA512' -ExpectedHash $Latest.Expected32ChecksumSHA512

    Confirm-Checksum -FilePath $filePath64 -Algorithm 'MD5' -ExpectedHash $Latest.Expected64ChecksumMD5
    Confirm-Checksum -FilePath $filePath64 -Algorithm 'SHA1' -ExpectedHash $Latest.Expected64ChecksumSHA1
    Confirm-Checksum -FilePath $filePath64 -Algorithm 'SHA256' -ExpectedHash $Latest.Expected64ChecksumSHA256
    Confirm-Checksum -FilePath $filePath64 -Algorithm 'SHA512' -ExpectedHash $Latest.Expected64ChecksumSHA512
}

function global:au_BeforeUpdate ($Package) {
    Read-ExpectedChecksums
    Get-RemoteFiles -Purge -NoSuffix
    Confirm-Checksums

    Add-ArchivedUrls

    Copy-Item -Path "$toolsPath\VERIFICATION.txt.template" -Destination "$toolsPath\VERIFICATION.txt" -Force

    Set-DescriptionFromReadme -Package $Package -ReadmePath '.\DESCRIPTION.md'
}

function global:au_AfterUpdate ($Package) {
    $rawLicense = [Regex]::Matches($response.Content, '<h4 class="utilsubject">License<\/h4>\n((.*\n){1,6})').Groups[1].Value
    $processedLicense = $rawLicense.Replace("`n", "`r`n")
    $rawDisclaimer = [Regex]::Matches($response.Content, '<h4 class="utilsubject">Disclaimer<\/h4>\n((.*\n){1,4})').Groups[1].Value
    $processedDisclaimer = ([System.Web.HttpUtility]::HtmlDecode($rawDisclaimer)).Replace("`n", "`r`n")

    Set-Content -Path 'tools\LICENSE.txt' -Value "From: $projectUri`r`n`r`nLicense`r`n`r`n$($processedLicense)`r`nDisclaimer`r`n`r`n$($processedDisclaimer)" -NoNewline
}

function global:au_SearchReplace {
    @{
        'build.ps1'                     = @{
            '(^\s*Url32\s*=\s*)(''.*'')' = "`$1'$($Latest.DirectArchivedDownloadURL32)'"
            '(^\s*Url64\s*=\s*)(''.*'')' = "`$1'$($Latest.DirectArchivedDownloadURL64)'"
        }
        "$($Latest.PackageName).nuspec" = @{
            '(<packageSourceUrl>)[^<]*(</packageSourceUrl>)' = "`$1https://github.com/brogers5/chocolatey-package-$($Latest.PackageName)/tree/v$($Latest.Version)`$2"
            '(<copyright>)[^<]*(</copyright>)'               = "`$1Copyright (c) 2012-$(Get-Date -Format yyyy) Nir Sofer`$2"
        }
        'tools\VERIFICATION.txt'        = @{
            '%archivedDownloadUrl32%' = "$($Latest.ArchivedDownloadURL32)"
            '%archivedDownloadUrl64%' = "$($Latest.ArchivedDownloadURL64)"
            '%archivedChecksumsUrl%'  = "$($Latest.ArchivedChecksumsURL)"
            '%md5Hash32%'             = "$($Latest.Expected32ChecksumMD5)"
            '%sha1Hash32%'            = "$($Latest.Expected32ChecksumSHA1)"
            '%sha256Hash32%'          = "$($Latest.Expected32ChecksumSHA256)"
            '%sha512Hash32%'          = "$($Latest.Expected32ChecksumSHA512)"
            '%md5Hash64%'             = "$($Latest.Expected64ChecksumMD5)"
            '%sha1Hash64%'            = "$($Latest.Expected64ChecksumSHA1)"
            '%sha256Hash64%'          = "$($Latest.Expected64ChecksumSHA256)"
            '%sha512Hash64%'          = "$($Latest.Expected64ChecksumSHA512)"
        }
    }
}

function global:au_GetLatest {
    $script:response = Invoke-WebRequest -Uri $projectUri -UserAgent $userAgent -UseBasicParsing

    $version = [Regex]::Matches($response.Content, '<td>MultiMonitorTool v(\d+(\.\d+){1,3})').Groups[1].Value

    return @{ 
        Url32           = 'https://www.nirsoft.net/utils/multimonitortool.zip'
        Url64           = 'https://www.nirsoft.net/utils/multimonitortool-x64.zip'
        Version         = $version
        SoftwareVersion = $Version #This may change if building a package fix version
    }
}

Update-Package -ChecksumFor None -NoReadme
