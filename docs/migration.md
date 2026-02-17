# Migration Guide

This guide helps users migrate from previous versions of scoop-cn, particularly addressing changes related to bucket name handling.

## Breaking Changes in v2.0

### Hardcoded Bucket Name Removal

**Previous Behavior:**
- Generated manifests contained hardcoded references to `scoop-cn` as the bucket name
- Dependencies were prefixed with `scoop-cn/` (e.g., `"depends": "scoop-cn/ffmpeg"`)
- Scripts paths were rewritten to use `scoop-cn` explicitly

**New Behavior:**
- Bucket names are no longer hardcoded in manifests
- Dependencies use unqualified names (e.g., `"depends": "ffmpeg"`)
- Scripts paths are preserved as-is from upstream

### Why This Changed

The previous approach assumed users would always name their bucket `scoop-cn`. However, users can add buckets with any name:

```powershell
scoop bucket add my-mirror https://github.com/lvyuemeng/scoop-cn
```

Hardcoded names caused issues when users chose different bucket names.

## Migration Steps

### If You Used the Default Bucket Name (`scoop-cn`)

No action required. Your setup will continue to work.

### If You Used a Custom Bucket Name

Your setup will now work correctly! The previous issues with custom bucket names have been resolved.

**What was broken before:**
```powershell
# User adds bucket with custom name
scoop bucket add my-mirror https://github.com/lvyuemeng/scoop-cn

# Manifests contained hardcoded paths like:
"$bucketsdir\scoop-cn\scripts\..."  # This failed if bucket was named "my-mirror"
```

**What works now:**
```powershell
# User adds bucket with any name
scoop bucket add my-mirror https://github.com/lvyuemeng/scoop-cn

# Paths are resolved naturally by Scoop regardless of bucket name
```

### Updating Existing Installations

If you have existing apps installed from this bucket, you may want to update their `install.json`:

```powershell
# Update install.json to reference your actual bucket name
$bucketName = "spc"  # or whatever you named it
Get-ChildItem -Path "$env:USERPROFILE\scoop\apps" -Recurse -Filter "install.json" | ForEach-Object { 
    (Get-Content -Path $_.FullName -Raw) -replace '"bucket": "scoop-cn"', "`"bucket`": `"$bucketName`"" | Set-Content -Path $_.FullName 
}
```

### For Package Maintainers

If you maintain packages that reference this bucket:

1. **Scripts paths**: No longer need special handling - use standard Scoop variables like `$dir`, `$persist_dir`
2. **Dependencies**: Use unqualified names (e.g., `"depends": "ffmpeg"`) instead of bucket-qualified names
3. **Suggest fields**: Same as dependencies - use unqualified names

## Verification

Verify your migration:

```powershell
# Check that no hardcoded scoop-cn references remain in your installed apps
Get-ChildItem "$env:USERPROFILE\scoop\apps" -Recurse -Filter "*.json" | 
    Select-String -Pattern "scoop-cn" | 
    Select-Object Filename, LineNumber, Line
```

## Rollback

If you need to rollback to the previous behavior (not recommended):

1. Edit `bin/config.ps1`
2. Find the disabled rules (marked with "DISABLED")
3. Change `enabled = $false` to `enabled = $true`

The disabled rules are:
- "Fix: Internal 'scripts' paths - DISABLED"
- "Fix: Internal 'suggest' paths - DISABLED"  
- "Fix: Internal 'depends' paths - DISABLED"

## Support

If you encounter issues during migration:

1. Check that your bucket name is consistent in all commands
2. Verify your Scoop installation is up to date: `scoop update scoop`
3. Re-add the bucket if needed: `scoop bucket rm <name>` then `scoop bucket add <name> <url>`

## Summary

| Aspect | Before | After |
|--------|--------|-------|
| Bucket name flexibility | Required "scoop-cn" | Any name works |
| Dependencies | `"scoop-cn/package"` | `"package"` |
| Scripts paths | Hardcoded rewrite | Preserved from upstream |
| Migration effort | None if using "scoop-cn" | None - just works now |
