$Script:BIN_ROOT = $PSScriptRoot
$Script:ROOT = (Get-Item $PSScriptRoot).Parent.FullName
$Script:BUCKET_DIR = Join-Path $Script:ROOT "bucket"
$Script:SCRIPTS_DIR = Join-Path $Script:ROOT "scripts"
$Script:JsonValidationFailures = 0

# Safely load the configuration
$ConfigFile = Join-Path $Script:BIN_ROOT "config.ps1"
if (-not (Test-Path $ConfigFile)) {
    throw "Configuration file not found at $ConfigFile"
}
$Script:CONTEXT = & $ConfigFile

function Expand-Variables {
    [CmdletBinding()]
    param(
        [string]$Text,
        [hashtable]$Vars
    )

    if ([string]::IsNullOrWhiteSpace($Text) -or $null -eq $Vars) { return $Text }

    $prevText = $null
    while ($Text -ne $prevText) {
        $prevText = $Text
        foreach ($key in $Vars.Keys) {
            $pattern = '\$\{' + [regex]::Escape($key) + '\}'
            $Text = $Text -replace $pattern, $Vars[$key]
        }
    }
    return $Text
}

function Update-Manifest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][System.IO.FileInfo]$Manifest,
        [Parameter(Mandatory)][array]$ExpandedRules,
        [switch]$DryRun
    )

    $content = [System.IO.File]::ReadAllText($Manifest.FullName)
    $isChange = $false
    $lastAppliedRule = $null

    # Apply all enabled rules
    foreach ($rule in $ExpandedRules) {
        if ($content -match $rule.find) {
            Write-Verbose "[$($Manifest.Name)] Applying rule: $($rule.description)"
            $content = $content -replace $rule.find, $rule.replace
            $isChange = $true
            $lastAppliedRule = $rule.description
        }
    }

    if (-not $isChange) { return }

    # Validate JSON before committing changes
    try {
        $null = ConvertFrom-Json -InputObject $content -ErrorAction Stop
    } catch {
        Write-Error "[$($Manifest.Name)] Invalid JSON after applying rule: '$lastAppliedRule'. Error: $_"
        $Script:JsonValidationFailures++
        return
    }

    if ($DryRun) {
        Write-Host "DRY RUN: Would have modified $($Manifest.Name)" -ForegroundColor Yellow
    } else {
        Write-Verbose "Updating $($Manifest.FullName)"
        [System.IO.File]::WriteAllText($Manifest.FullName, $content, [System.Text.UTF8Encoding]::new($false))
    }
}

# --- PART 1: AGGREGATION ---
function Invoke-BucketAggregation {
    [CmdletBinding()]
    param([string[]]$Repos)

    Write-Host "Starting bucket aggregation for $($Repos.Count) repositories..." -ForegroundColor Cyan

    # Ensure clean slate for output directories
    $directories = @($Script:BUCKET_DIR, $Script:SCRIPTS_DIR)
    Remove-Item -Path $directories -Recurse -Force -ErrorAction SilentlyContinue
    $directories | ForEach-Object { $null = New-Item -ItemType Directory -Path $_ -Force }

    foreach ($repo in $Repos) {
        $bucketName = $repo.Split('/')[-1]
        $targetPath = Join-Path $Script:ROOT $bucketName

        # Wipe old clone if it was left behind
        if (Test-Path $targetPath) { Remove-Item -Path $targetPath -Recurse -Force }

        Write-Host "Cloning $repo -> $bucketName"
        $gitArgs = @("clone", "--depth", "1", "--quiet", "https://github.com/$repo.git", $targetPath)
        & git @gitArgs

        Write-Verbose "Aggregating contents of $bucketName..."
        $sourceBucket = Join-Path $targetPath "bucket"
        $sourceScripts = Join-Path $targetPath "scripts"

        if (Test-Path $sourceBucket) {
            Copy-Item -Path (Join-Path $sourceBucket "*") -Destination $Script:BUCKET_DIR -Recurse -Force
        } elseif (Test-Path $targetPath) {
            # Some buckets have manifests directly in the root
            Get-ChildItem -Path $targetPath -Filter "*.json" | Copy-Item -Destination $Script:BUCKET_DIR -Force
        }

        if (Test-Path $sourceScripts) {
            Copy-Item -Path (Join-Path $sourceScripts "*") -Destination $Script:SCRIPTS_DIR -Recurse -Force
        }
    }
    Write-Host "Aggregation complete." -ForegroundColor Green
}

# --- PART 2: URL REPLACEMENT ---
function Invoke-Replacement {
    [CmdletBinding()]
    param(
        [array]$Rules,
        [hashtable]$Vars,
        [switch]$DryRun
    )

    Write-Host "Applying replacement rules..." -ForegroundColor Cyan

    # Pre-compile the rules to save CPU cycles inside the file loop
    $expandedRules = foreach ($rule in $Rules) {
        if (-not $rule.enabled) { continue }

        [PSCustomObject]@{
            description = $rule.description
            find        = $rule.find
            replace     = Expand-Variables -Text $rule.replace -Vars $Vars
        }
    }

    if (-not $expandedRules) {
        Write-Warning "No enabled rules found. Skipping replacements."
        return
    }

    Write-Host "Applying $($expandedRules.Count) active rules..."
    $manifests = Get-ChildItem -Path $Script:BUCKET_DIR -Filter "*.json" -Recurse

    foreach ($manifest in $manifests) {
        Update-Manifest -Manifest $manifest -ExpandedRules $expandedRules -DryRun:$DryRun
    }
    Write-Host "Replacement complete." -ForegroundColor Green
}

# --- PART 3: CLEANUP ---
function Invoke-Cleanup {
    [CmdletBinding()]
    param([string[]]$Repos)

    Write-Host "Cleaning up cloned repository folders..." -ForegroundColor Cyan
    foreach ($repo in $Repos) {
        $bucketName = $repo.Split('/')[-1]
        $targetPath = Join-Path $Script:ROOT $bucketName

        if (Test-Path $targetPath) {
            Remove-Item -Path $targetPath -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

# --- PART 4: POST-PROCESSING ---
function Invoke-PostProcess {
    [CmdletBinding()]
    param([array]$PostProcess)

    if (-not $PostProcess) { return }

    Write-Host "Running post-processing actions..." -ForegroundColor Cyan

    foreach ($proc in $PostProcess) {
        if (-not $proc.enabled) { continue }

        $bucketName = $proc.repo.Split('/')[-1]
        $sourcePath = Join-Path $Script:ROOT $bucketName

        Write-Host "  Executing: [$($proc.description)]"

        if ($proc.action -eq "rename") {
            $fromPath = Join-Path $sourcePath $proc.from
            $toPath = Join-Path $Script:BUCKET_DIR $proc.to

            if (Test-Path $fromPath) {
                Write-Verbose "    Renaming $($proc.from) -> $($proc.to)"
                Move-Item -Path $fromPath -Destination $toPath -Force
            } else {
                Write-Warning "    Source path not found: $fromPath"
            }
        }
    }
    Write-Host "Post-processing complete." -ForegroundColor Green
}

# --- ENTRY POINT ---
function Invoke-Entry {
    [CmdletBinding()]
    param([switch]$DryRun)

    try {
        Invoke-BucketAggregation -Repos $Script:CONTEXT.repositories
        Invoke-PostProcess -PostProcess $Script:CONTEXT.postprocess
        Invoke-Replacement -Rules $Script:CONTEXT.rules -Vars $Script:CONTEXT.proxies -DryRun:$DryRun
    } finally {
        # Ensures repos are deleted even if user hits Ctrl+C or a syntax error crashes the pipeline
        Invoke-Cleanup -Repos $Script:CONTEXT.repositories
    }

    Write-Host "Update process complete." -ForegroundColor Green

    if ($Script:JsonValidationFailures -gt 0) {
        Write-Warning "Completed with $Script:JsonValidationFailures JSON validation failure(s)."
    }
}
