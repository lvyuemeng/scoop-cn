#Requires -Version 5.1

<#
.SYNOPSIS
    Scoop-CN Installer
.DESCRIPTION
    Installs Scoop with Chinese mirror/proxy support.
.PARAMETER UseProxy
    Use Chinese proxy mirrors (default: prompt)
.PARAMETER ScoopDir
    Scoop installation directory (default: $env:USERPROFILE\scoop)
.PARAMETER BucketName
    Bucket alias for scoop-cn (default: spc)
.EXAMPLE
    .\installer.ps1 -UseProxy -BucketName my-mirror
#>
[CmdletBinding()]
param(
    [switch]$UseProxy,
    [string]$ScoopDir   = "$env:USERPROFILE\scoop",
    [string]$BucketName = 'spc'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

#region helpers
filter Write-Step   { Write-Host $_ -ForegroundColor Cyan    }
filter Write-Ok     { Write-Host $_ -ForegroundColor Green   }
filter Write-Warn   { Write-Host $_ -ForegroundColor Yellow  }
filter Write-Fail   { Write-Host $_ -ForegroundColor Red     }

function Test-Admin {
    ([Security.Principal.WindowsPrincipal](
        [Security.Principal.WindowsIdentity]::GetCurrent()
    )).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Prompt-YN([string]$question) {
    (Read-Host $question) -match '^[Yy]$'
}
#endregion

#region install
function Install-Scoop {
    if ($UseProxy) {
        'Installing Scoop via proxy mirror...' | Write-Step
        $tmp = "$env:TEMP\scoop-install.ps1"
        Invoke-WebRequest -Uri 'https://scoop.201704.xyz' -OutFile $tmp
        try { & $tmp } finally { Remove-Item $tmp -Force -ErrorAction SilentlyContinue }
    } else {
        'Installing Scoop via official source...' | Write-Step
        Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
    }
    'Scoop installed.' | Write-Ok
}

function Set-ScoopConfig {
    'Configuring Scoop...' | Write-Step
    if ($UseProxy) {
        scoop config SCOOP_REPO 'https://gitee.com/scoop-installer/scoop'
    }
    if ($ScoopDir -ne "$env:USERPROFILE\scoop") {
        [Environment]::SetEnvironmentVariable('SCOOP', $ScoopDir, 'User')
        $env:SCOOP = $ScoopDir
    }
}

function Add-Bucket {
    $url = if ($UseProxy) {
        'https://gh-proxy.org/https://github.com/lvyuemeng/scoop-cn'
    } else {
        'https://github.com/lvyuemeng/scoop-cn'
    }
    "Adding bucket '$BucketName'..." | Write-Step
    $existing = scoop bucket list 2>$null
    if ($existing -match $BucketName) {
        "Bucket '$BucketName' exists; replacing." | Write-Warn
        scoop bucket rm $BucketName
    }
    scoop bucket add $BucketName $url
    "Bucket '$BucketName' added." | Write-Ok
}

function Update-AppBucketRefs {
    $pattern = '"bucket":\s*"(main|extras|versions|nirsoft|sysinternals|php|nerd-fonts|nonportable|java|games)"'
    $files   = Get-ChildItem -Path "$ScoopDir\apps" -Recurse -Filter 'install.json' -ErrorAction SilentlyContinue
    $n = 0
    foreach ($f in $files) {
        $raw = Get-Content $f.FullName -Raw -ErrorAction SilentlyContinue
        if ($raw -match $pattern) {
            $raw -replace $pattern, "`"bucket`": `"$BucketName`"" | Set-Content $f.FullName -Force
            $n++
        }
    }
    if ($n) { "Updated $n app(s) to bucket '$BucketName'." | Write-Ok }
}

function Show-Summary {
    Write-Host ''
    '========================================' | Write-Ok
    "  Bucket : $BucketName" | Write-Ok
    "  Dir    : $ScoopDir"   | Write-Ok
    "  Proxy  : $UseProxy"   | Write-Ok
    if ($UseProxy) {
        "  Repo   : https://gitee.com/scoop-installer/scoop" | Write-Ok
    }
    '========================================' | Write-Ok
    "scoop install $BucketName/<package>" | Write-Ok
    Write-Host ''
}
#endregion

# ── main ──────────────────────────────────────────────────────────────────────

if ($PSVersionTable.PSVersion.Major -lt 5) {
    'PowerShell 5.1+ is required.' | Write-Fail; exit 1
}

if (Test-Admin) {
    'Running as Administrator is not recommended for Scoop.' | Write-Warn
    if (-not (Prompt-YN 'Continue anyway? (y/N)')) { exit 0 }
}

if (Get-Command scoop -ErrorAction SilentlyContinue) {
    'Scoop is already installed.' | Write-Warn
    if (-not (Prompt-YN 'Reconfigure only? (y/N)')) {
        $UseProxy = $UseProxy -or (Prompt-YN 'Use proxy mirrors? (y/N)')
        Set-ScoopConfig; Add-Bucket; Update-AppBucketRefs; Show-Summary; exit 0
    }
}

if (-not $UseProxy) {
    $UseProxy = Prompt-YN 'Use Chinese proxy mirrors? (y/N)'
}

if ((Get-ExecutionPolicy) -eq 'Restricted') {
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
}

try {
    Install-Scoop
    Set-ScoopConfig
    Add-Bucket
    Update-AppBucketRefs
    $env:Path = [Environment]::GetEnvironmentVariable('Path','User') + ';' +
                [Environment]::GetEnvironmentVariable('Path','Machine')
} catch {
    "Installation failed: $_" | Write-Fail; exit 1
}

Show-Summary
