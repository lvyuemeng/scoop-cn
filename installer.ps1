#Requires -Version 5.1

<#
.SYNOPSIS
    Scoop-CN Installer Script
.DESCRIPTION
    Installs Scoop with Chinese mirror/proxy support for users behind network restrictions.
    Provides both official and proxied installation methods.
.PARAMETER UseProxy
    Use Chinese proxy mirrors for installation (default: prompt user)
.PARAMETER ScoopDir
    Custom Scoop installation directory (default: $env:USERPROFILE\scoop)
.PARAMETER BucketName
    Name for the scoop-cn bucket (default: spc)
.EXAMPLE
    .\installer.ps1
    # Interactive installation with prompt for proxy usage
.EXAMPLE
    .\installer.ps1 -UseProxy
    # Use proxy mirrors automatically
.EXAMPLE
    .\installer.ps1 -UseProxy -BucketName "my-mirror"
    # Use proxy with custom bucket name
.NOTES
    This installer is specifically designed for Chinese users who may have
    difficulty accessing GitHub directly.
#>

[CmdletBinding()]
param(
    [switch]$UseProxy,
    [string]$ScoopDir = "$env:USERPROFILE\scoop",
    [string]$BucketName = "spc"
)

# Error action preference
$ErrorActionPreference = "Stop"

function Write-Info {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Red
}

function Test-Admin {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Install-ScoopOfficial {
    Write-Info "Installing Scoop using official method..."
    try {
        Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
        Write-Success "Scoop installed successfully via official method."
    } catch {
        Write-Error "Failed to install Scoop via official method: $_"
        throw
    }
}

function Install-ScoopProxy {
    Write-Info "Installing Scoop using Chinese proxy mirror..."
    try {
        $installScript = "$env:TEMP\scoop-install.ps1"
        Invoke-WebRequest -Uri "https://scoop.201704.xyz" -OutFile $installScript
        & $installScript
        Remove-Item $installScript -Force -ErrorAction SilentlyContinue
        Write-Success "Scoop installed successfully via proxy mirror."
    } catch {
        Write-Error "Failed to install Scoop via proxy: $_"
        throw
    }
}

function Set-ScoopConfig {
    param(
        [switch]$UseProxy
    )

    Write-Info "Configuring Scoop..."

    if ($UseProxy) {
        # Set Scoop repository to Gitee mirror
        Write-Info "Setting Scoop repository to Gitee mirror..."
        scoop config SCOOP_REPO "https://gitee.com/scoop-installer/scoop"

        # Set proxy for scoop updates
        Write-Info "Configuring proxy settings..."
        scoop config proxy "https://gh-proxy.org"
    }

    # Set custom installation directory if specified
    if ($ScoopDir -ne "$env:USERPROFILE\scoop") {
        Write-Info "Setting custom Scoop directory: $ScoopDir"
        [Environment]::SetEnvironmentVariable('SCOOP', $ScoopDir, 'User')
        $env:SCOOP = $ScoopDir
    }

    Write-Success "Scoop configuration completed."
}

function Add-ScoopCNBucket {
    param(
        [string]$BucketName
    )

    Write-Info "Adding scoop-cn bucket as '$BucketName'..."

    $bucketUrl = if ($UseProxy) {
        "https://gh-proxy.org/https://github.com/lvyuemeng/scoop-cn"
    } else {
        "https://github.com/lvyuemeng/scoop-cn"
    }

    try {
        # Remove existing bucket if present
        $existingBuckets = scoop bucket list 2>$null
        if ($existingBuckets -match $BucketName) {
            Write-Warning "Bucket '$BucketName' already exists. Removing and re-adding..."
            scoop bucket rm $BucketName
        }

        # Add the bucket
        scoop bucket add $BucketName $bucketUrl
        Write-Success "Bucket '$BucketName' added successfully."
    } catch {
        Write-Error "Failed to add bucket: $_"
        throw
    }
}

function Update-ExistingApps {
    param(
        [string]$BucketName
    )

    Write-Info "Checking for existing apps to update bucket references..."

    $installJsonPaths = Get-ChildItem -Path "$ScoopDir\apps" -Recurse -Filter "install.json" -ErrorAction SilentlyContinue

    if (-not $installJsonPaths) {
        Write-Info "No existing apps found."
        return
    }

    $updatedCount = 0
    foreach ($jsonPath in $installJsonPaths) {
        try {
            $content = Get-Content $jsonPath.FullName -Raw -ErrorAction SilentlyContinue
            if ($content -match '"bucket":\s*"(main|extras|versions|nirsoft|sysinternals|php|nerd-fonts|nonportable|java|games)"') {
                $newContent = $content -replace '"bucket":\s*"(main|extras|versions|nirsoft|sysinternals|php|nerd-fonts|nonportable|java|games)"', "`"bucket`": `"$BucketName`""
                Set-Content -Path $jsonPath.FullName -Value $newContent -Force
                $updatedCount++
            }
        } catch {
            Write-Warning "Failed to update $($jsonPath.FullName): $_"
        }
    }

    if ($updatedCount -gt 0) {
        Write-Success "Updated $updatedCount app(s) to reference '$BucketName' bucket."
    } else {
        Write-Info "No apps needed updating."
    }
}

function Show-PostInstallInfo {
    param(
        [string]$BucketName,
        [switch]$UseProxy
    )

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "    Scoop-CN Installation Complete!    " -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Configuration Summary:" -ForegroundColor Cyan
    Write-Host "  - Bucket Name: $BucketName" -ForegroundColor White
    Write-Host "  - Installation Directory: $ScoopDir" -ForegroundColor White
    Write-Host "  - Proxy Enabled: $UseProxy" -ForegroundColor White
    Write-Host ""

    if ($UseProxy) {
        Write-Host "Proxy Settings:" -ForegroundColor Cyan
        Write-Host "  - Scoop Repo: https://gitee.com/scoop-installer/scoop" -ForegroundColor White
        Write-Host "  - Bucket URL: https://gh-proxy.org/https://github.com/lvyuemeng/scoop-cn" -ForegroundColor White
        Write-Host ""
    }

    Write-Host "Quick Start:" -ForegroundColor Cyan
    Write-Host "  - Search packages:  scoop search <package>" -ForegroundColor White
    Write-Host "  - Install package:  scoop install $BucketName/<package>" -ForegroundColor White
    Write-Host "  - List installed:   scoop list" -ForegroundColor White
    Write-Host "  - Update all:       scoop update *" -ForegroundColor White
    Write-Host ""
    Write-Host "For more information, visit: https://github.com/lvyuemeng/scoop-cn" -ForegroundColor Cyan
    Write-Host ""
}

# ==================== MAIN EXECUTION ====================

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "     Scoop-CN Installer v1.0          " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as admin (not required, but warn if so)
if (Test-Admin) {
    Write-Warning "Running as Administrator. Scoop does not require admin privileges."
    Write-Warning "It's recommended to run this installer as a regular user."
    Write-Host ""
    $continue = Read-Host "Continue anyway? (y/N)"
    if ($continue -notmatch '^[Yy]$') {
        Write-Info "Installation cancelled."
        exit 0
    }
}

# Check PowerShell version
if ($PSVersionTable.PSVersion.Major -lt 5) {
    Write-Error "PowerShell 5.1 or higher is required. You have $($PSVersionTable.PSVersion)"
    exit 1
}

# Check if Scoop is already installed
$scoopInstalled = Get-Command scoop -ErrorAction SilentlyContinue
if ($scoopInstalled) {
    Write-Warning "Scoop is already installed."
    $reinstall = Read-Host "Reinstall/Configure anyway? (y/N)"
    if ($reinstall -notmatch '^[Yy]$') {
        # Just configure bucket
        if (-not $UseProxy) {
            $useProxyChoice = Read-Host "Use proxy mirrors for better connectivity in China? (y/N)"
            $UseProxy = $useProxyChoice -match '^[Yy]$'
        }

        Set-ScoopConfig -UseProxy:$UseProxy
        Add-ScoopCNBucket -BucketName $BucketName
        Update-ExistingApps -BucketName $BucketName
        Show-PostInstallInfo -BucketName $BucketName -UseProxy:$UseProxy
        exit 0
    }
}

# Prompt for proxy usage if not specified
if (-not $UseProxy) {
    Write-Info "Are you in China or behind network restrictions?"
    Write-Info "The proxy option uses Chinese mirrors for better connectivity."
    Write-Host ""
    $useProxyChoice = Read-Host "Use proxy mirrors? (y/N)"
    $UseProxy = $useProxyChoice -match '^[Yy]$'
}

# Set execution policy if needed
$currentPolicy = Get-ExecutionPolicy
if ($currentPolicy -eq 'Restricted') {
    Write-Info "Setting execution policy to RemoteSigned..."
    try {
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        Write-Success "Execution policy updated."
    } catch {
        Write-Error "Failed to set execution policy. Please run: Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser"
        exit 1
    }
}

# Install Scoop
try {
    if ($UseProxy) {
        Install-ScoopProxy
    } else {
        Install-ScoopOfficial

        # Configure Scoop
        Set-ScoopConfig -UseProxy:$UseProxy

        # Add scoop-cn bucket
        Add-ScoopCNBucket -BucketName $BucketName

        # Update existing apps to use new bucket
        Update-ExistingApps -BucketName $BucketName
    }

    # Refresh environment to get scoop command
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "User") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "Machine")
} catch {
    Write-Error "Installation failed: $_"
    exit 1
}

# Show completion info
Show-PostInstallInfo -BucketName $BucketName -UseProxy:$UseProxy

Write-Success "Installation complete! You can now use 'scoop install $BucketName/<package>'"
