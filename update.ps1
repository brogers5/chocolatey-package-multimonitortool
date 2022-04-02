Import-Module au

function global:au_BeforeUpdate ($Package)  {
    Set-DescriptionFromReadme -Package $Package -ReadmePath ".\DESCRIPTION.md"
}

function global:au_AfterUpdate ($Package)  {
    
}

function global:au_SearchReplace {
    @{
        "$($Latest.PackageName).nuspec" = @{
            "<packageSourceUrl>[^<]*</packageSourceUrl>" = "<packageSourceUrl>https://github.com/brogers5/chocolatey-package-$($Latest.PackageName)/tree/v$($Latest.Version)</packageSourceUrl>"
            "<copyright>[^<]*</copyright>" = "<copyright>Copyright (c) 2012-$(Get-Date -Format yyyy) Nir Sofer</copyright>"
        }
        'tools\chocolateyInstall.ps1' = @{
            "(^[$]url\s*=\s*)('.*')" = "`$1'$($Latest.Url32)'"
            "(^[$]checksum\s*=\s*)('.*')" = "`$1'$($Latest.Checksum32)'"
            "(^[$]url64\s*=\s*)('.*')" = "`$1'$($Latest.Url64)'"
            "(^[$]checksum64\s*=\s*)('.*')" = "`$1'$($Latest.Checksum64)'"
        }
    }
}

function global:au_GetLatest {
    # Query the latest version
    $uri = 'https://www.nirsoft.net/utils/multi_monitor_tool.html'
    $page = Invoke-WebRequest -Uri $uri -UserAgent "Update checker of Chocolatey Community Package 'multimonitortool'"

    $version = [Version] [Regex]::Matches($page.Content, "<li>Version (.*):?").Groups[1].Value

    return @{ 
        Url32 = 'https://www.nirsoft.net/utils/multimonitortool.zip'
        Url64 = 'https://www.nirsoft.net/utils/multimonitortool-x64.zip'
        Version = $version
        SoftwareVersion = $Version #This may change if building a package fix version
    }
}

Update-Package -NoReadme
