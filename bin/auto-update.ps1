[CmdletBinding()]
param (
	[Switch]$DryRun
)

$BIN_ROOT = $PSScriptRoot
$ROOT = (Get-Item $PSScriptRoot).Parent.FullName
$BUCKET_DIR = Join-Path $ROOT "bucket"
$SCRIPTS_DIR = Join-Path $ROOT "scripts"
# Safety: $Root\config.json = <repo>\bin\config.json
$Context = & "$BIN_ROOT\config.ps1"

# --- PART 1: AGGREGATION ---
function aggregation {
	param(
		$repositories
	)

	Write-Host "Starting bucket aggregation..."
	Write-Host "Found $($repositories.Count) official repositories."

	# Clear old buckets
	Remove-Item -Path $BUCKET_DIR -Recurse -Force -ErrorAction SilentlyContinue
	Remove-Item -Path $SCRIPTS_DIR -Recurse -Force -ErrorAction SilentlyContinue
	New-Item -ItemType Directory -Path $BUCKET_DIR
	New-Item -ItemType Directory -Path $SCRIPTS_DIR

	# List buckets in context
	$buckets = $repositories | ForEach-Object {
		$_.Split('/')[-1]
	}

	# Safety: Our repo contains all pulled buckets repo.
	foreach ($bucket in $buckets) {
		Write-Verbose "Aggregating $bucket..."
		$SourceBucket = Join-Path $Root $bucket "bucket"
		$SourceScripts = Join-Path $Root $bucket "scripts"
		
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
function replacement {
	param(
		$rules
	)
	Write-Host "Loading and applying replacement rules..."
	# Load and filter for only enabled rules
	$rules = $rules | Where-Object { $_.enabled -eq $true }

	if ($rules.Count -eq 0) {
		Write-Warning "No enabled rules found in config.json. Skipping replacement."
	} else {
		Write-Host "Applying $($rules.Count) enabled replacement rules..."
	}

	$manifests = Get-ChildItem -Recurse -Path $BUCKET_DIR -Filter "*.json"

	foreach ($man in $manifests) {
		$content = Get-Content -Path $man.FullName -Raw
		$isChange = $false

		# Apply all enabled rules
		foreach ($rule in $rules) {
			if ($content -match $rule.find) {
				Write-Verbose "[$($man.Name)] Applying rule: $($rule.description)"
				$content = $content -replace $rule.find, $rule.replace
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
}

# --- PART 3: CLEANUP ---
function cleanup {
	param(
		$repositories
	)

	Write-Host "Cleaning up source bucket folders..."
	$repositories | ForEach-Object {
		$bucket = $_.Split('/')[-1]
		Remove-Item -Path (Join-Path $ROOT $bucket) -Recurse -Force
	}
}

aggregation $Context.repositories
replacement $Context.rules
cleanup $Context.repositories
Write-Host "Update process complete."