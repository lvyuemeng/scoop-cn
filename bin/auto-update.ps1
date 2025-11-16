[CmdletBinding()]
param (
	[Switch]$DryRun
)

. "$PSScriptRoot\lib.ps1"

Invoke-Entry -DryRun:$DryRun