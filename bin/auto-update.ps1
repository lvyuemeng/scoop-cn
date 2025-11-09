[CmdletBinding()]
param (
	[Switch]$DryRun
)

# --- PART 1: AGGREGATION ---
Write-Host "Starting bucket aggregation..."

$BinRoot = $PSScriptRoot
$Root = (Get-Item $PSScriptRoot).Parent.FullName
$BucketDir = Join-Path $Root "bucket"
$ScriptsDir = Join-Path $Root "scripts"
# Safety: $Root\config.json = <repo>\bin\config.json
$Context = Get-Content -Path ("$BinRoot\config.json") -Raw | ConvertFrom-Json
Write-Host "Found $($Context.repositories.Count) official repositories."

# Clear old buckets
Remove-Item -Path $BucketDir -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path $ScriptsDir -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path $BucketDir
New-Item -ItemType Directory -Path $ScriptsDir

# List buckets in context
$Buckets = $Context.repositories | ForEach-Object {
	$_.Split('/')[-1]
}

# Safety: Our repo contains all pulled buckets repo.
foreach ($bucket in $Buckets) {
	Write-Verbose "Aggregating $bucket..."
	$SourceBucket = Join-Path $Root $bucket "bucket"
	$SourceScripts = Join-Path $Root $bucket "scripts"
    
	if (Test-Path $SourceBucket) {
		Copy-Item -Path (Join-Path $SourceBucket "*") -Destination $BucketDir -Recurse -Force
	}
	if (Test-Path $SourceScripts) {
		Copy-Item -Path (Join-Path $SourceScripts "*") -Destination $ScriptsDir -Recurse -Force
	}
}
Write-Host "Aggregation complete."

# --- PART 2: URL REPLACEMENT ---
Write-Host "Loading and applying replacement rules..."
# Load and filter for only enabled rules
$rules = $Context.rules | Where-Object { $_.enabled -eq $true }

if ($rules.Count -eq 0) {
	Write-Warning "No enabled rules found in config.json. Skipping replacement."
} else {
	Write-Host "Applying $($rules.Count) enabled replacement rules..."
}

$manifests = Get-ChildItem -Recurse -Path $BucketDir -Filter "*.json"

foreach ($man in $manifests) {
	$content = Get-Content -Path $man.FullName -Raw
	$isChange = $false

	# Apply all enabled rules
	foreach ($rule in $rules) {
		if ($content -match $rule.find) {
			Write-Verbose "[$($man.Name)] Applying rule: $($rule.description)"
			$content = $content -replace [Regex]::Escape($rule.find), $rule.replace
			$isChange = $true
		}
	}

	# Write the file back *only* if changes were made
	if ($isChange) {
		if ($DryRun) {
			Write-Warning "DRY RUN: Would have modified $($man.FullName)"
		} else {
			Write-Host "Updating $($man.FullName)"
			Set-Content -Path $man.FullName -Value $content -NoNewline -Encoding utf8NoBOM
		}
	}
}

# --- PART 3: CLEANUP ---
Write-Host "Cleaning up source bucket folders..."
foreach ($bucket in $Buckets) {
	Remove-Item -Path (Join-Path $Root $bucket) -Recurse -Force
}

Write-Host "Update process complete."