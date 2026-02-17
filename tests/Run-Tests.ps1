#Requires -Module Pester

<#
.SYNOPSIS
    Test runner for scoop-cn test suite
.DESCRIPTION
    Runs all Pester tests for the scoop-cn project
#>

param(
    [switch]$VerboseOutput,
    [string]$TestPath = $PSScriptRoot
)

# Ensure Pester is available
if (-not (Get-Module -ListAvailable -Name Pester)) {
    Write-Host "Installing Pester..." -ForegroundColor Yellow
    Install-Module -Name Pester -Force -SkipPublisherCheck -Scope CurrentUser
}

# Import Pester
Import-Module Pester -MinimumVersion 5.0

# Configure Pester
$config = New-PesterConfiguration
$config.Run.Path = $TestPath
$config.Run.PassThru = $true
$config.Output.Verbosity = if ($VerboseOutput) { "Detailed" } else { "Normal" }

# Run tests
Write-Host "Running scoop-cn tests..." -ForegroundColor Cyan
$results = Invoke-Pester -Configuration $config

# Exit with appropriate code
exit $results.FailedCount
