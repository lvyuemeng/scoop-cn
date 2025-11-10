$BIN_ROOT = $PSScriptRoot
$Context = & "$BIN_ROOT\config.ps1"
Write-Host "Found $($Context.repositories.Count) repositories to clone."

foreach ($repo in $Context.repositories) {
	$path = $repo.Split('/')[-1]
	Write-Host "Cloning $repo to $path"
	& git clone --depth 1 "https://github.com/$repo.git" $path
}