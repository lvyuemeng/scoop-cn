$BIN_ROOT = $PSScriptRoot
$ROOT = (Get-Item $PSScriptRoot).Parent.FullName
$BUCKET_DIR = Join-Path $ROOT "bucket"
$SCRIPTS_DIR = Join-Path $ROOT "scripts"

# Safety: $PScriptRoot\config.ps1 = <root>\bin\config.json
$CONTEXT = & "$BIN_ROOT\config.ps1"

function Expand-Variables {
	param(
		[string]$text,
		[hashtable]$vars
	)
	
	$prevText = $null
	while ($text -ne $prevText) {
		$prevText = $text
		foreach ($key in $vars.Keys) {
			$pattern = '\$\{' + [Regex]::Escape($key) + '\}'
			$text = $text -replace $pattern, $vars[$key]
		}
	}
	return $text
}

function Update-Manifest {
	[CmdletBinding()]
	param(
		$manifest,
		$rules,
		$vars,
		[switch]$DryRun
	)

	$content = [System.IO.File]::ReadAllText($manifest.FullName)
	$isChange = $false

	# Apply all enabled rules
	foreach ($rule in $rules) {
		if ($content -match $rule["find"]) {
			Write-Verbose "[$($manifest.Name)] Applying rule: $($rule["description"])"
			$content = $content -replace $rule["find"], $rule["replace"]
			$isChange = $true
		}
	}

	# Write the file back *only* if changes were made
	if (-not $isChange) {
		return
	}

	if ($DryRun) {
		Write-Warning "DRY RUN: Would have modified $($manifest.FullName)"
	} else {
		Write-Host "Updating $($manifest.FullName)"
		[System.IO.File]::WriteAllText($manifest.FullName, $content, [Text.Encoding]::UTF8)
	}
}

# --- PART 1: AGGREGATION ---
function Invoke-BucketAggregation {
	[CmdletBinding()]
	param(
		[string[]]$repos
	)
	Write-Host "Starting bucket aggregation..."
	Write-Host "Found $($repos.Count) repositories."

	# Clear old buckets
	Remove-Item -Path $BUCKET_DIR, $SCRIPTS_DIR -Recurse -Force -ErrorAction SilentlyContinue
	New-Item -ItemType Directory -Path $BUCKET_DIR | Out-Null
	New-Item -ItemType Directory -Path $SCRIPTS_DIR | Out-Null

	# Safety: $repos should contains urls of repo
	foreach ($repo in $repos) {
		# $repo = <owner>/<$bucket>
		$bucket = $repo.Split('/')[-1]
		# clone repo: $ROOT/<bucket>
		Write-Host "Cloning $repo to $bucket"
		& git clone --depth 1 "https://github.com/$repo.git" $bucket

		Write-Verbose "Aggregating $bucket..."
		$SourceBucket = Join-Path (Get-Location).Path $bucket "bucket"
		$SourceScripts = Join-Path (Get-Location).Path $bucket "scripts"
		
		if (Test-Path $SourceBucket) {
			Copy-Item -Path (Join-Path $SourceBucket "*") -Destination $BUCKET_DIR -Recurse -Force
		}
		if (Test-Path $SourceScripts) {
			Copy-Item -Path (Join-Path $SourceScripts "*") -Destination $SCRIPTS_DIR -Recurse -Force
		}
	}
	Write-Host "Aggregation complete."
}

# --- PART 2: URL REPLACEMENT ---
function Invoke-Replacement {
	[CmdletBinding()]
	param(
		[PSCustomObject[]]$rules,
		[hashtable]$vars,
		[switch]$DryRun
	)
	Write-Host "Applying replacement rules..."

	Write-Debug "Rules: $($rules | Out-String)"
	$expandedRules = foreach ($rule in $rules) {
		if (-not $rule["enabled"]) { continue }

		[ordered]@{
			description = $rule["description"]
			find        = $rule["find"]
			replace     = Expand-Variables -text $rule["replace"] -vars $vars
		}
	}
	Write-Debug "Expanded rules: $($expandedRules | Out-String)"

	if ($expandedRules.Count -eq 0) {
		Write-Warning "No enabled rules found in config.ps1. Skipping replacement."
		return
	} else {
		Write-Host "Applying $($expandedRules.Count) enabled replacement rules..."
	}

	$manifests = Get-ChildItem -Recurse -Path $BUCKET_DIR -Filter "*.json"
	# Write-Debug "Manifests: $($manifests | Out-String)"

	$manifests | ForEach-Object {
		Update-Manifest -manifest $_ -rules $expandedRules -vars $vars -DryRun:$DryRun
	}
	Write-Host "Replacement complete."
}

# --- PART 3: CLEANUP ---
function Invoke-Cleanup {
	[CmdletBinding()]
	param(
		[string[]]$repos
	)

	Write-Host "Cleaning up source bucket folders..."
	$repos | ForEach-Object {
		$bucket = $_.Split('/')[-1]
		Remove-Item -Path (Join-Path $ROOT $bucket) -Recurse -Force -ErrorAction SilentlyContinue
	}
}

function Invoke-Entry {
	[CmdletBinding()]
	param(
		[switch]$DryRun
	)

	Invoke-BucketAggregation -repos $CONTEXT.repositories
	Invoke-Replacement -rules  $CONTEXT.rules -vars $CONTEXT.proxies -DryRun:$DryRun
	Invoke-Cleanup -repos $CONTEXT.repositories
	Write-Host "Update process complete."
}