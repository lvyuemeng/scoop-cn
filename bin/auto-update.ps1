[CmdletBinding()]
param (
	[Switch]$DryRun
)

. "$PSScriptRoot\lib.ps1"

Invoke-BucketAggregation -repos $Context.repositories
Invoke-Replacement -rules  $Context.rules -vars $Context.proxies -DryRun:$DryRun
Invoke-Cleanup -repos $Context.repositories
Write-Host "Update process complete."