

## [2026-02-17] NEW: Created installer.ps1

### Feature: Scoop-CN Installer Script
**Status**: COMPLETE
**File created**: `installer.ps1`

### Features
- Interactive and automated installation modes
- Supports both official and proxy installation methods
- Proxy mode uses `irm scoop.201704.xyz` for Chinese users
- Configures Scoop to use Gitee mirror when proxy mode enabled
- Automatically adds scoop-cn bucket as "spc"
- Updates existing app references to use new bucket name
- Handles custom installation directories
- Validates PowerShell version (requires 5.1+)
- Sets execution policy if needed
- Provides colored output and progress indicators

### Usage Examples
```powershell
# Interactive mode (prompts for proxy)
.\installer.ps1

# Use proxy automatically
.\installer.ps1 -UseProxy

# Custom bucket name
.\installer.ps1 -UseProxy -BucketName "my-mirror"

# Custom installation directory
.\installer.ps1 -UseProxy -ScoopDir "D:\scoop"
```

### Configuration Applied
- **SCOOP_REPO**: Set to `https://gitee.com/scoop-installer/scoop` when using proxy
- **Bucket URL**: `https://gh-proxy.org/https://github.com/lvyuemeng/scoop-cn`
- **Bucket Name**: Configurable (default: "spc")
- **Execution Policy**: Set to RemoteSigned if Restricted

### Functions
- `Install-ScoopOfficial` - Official Scoop installation
- `Install-ScoopProxy` - Proxy-based installation via scoop.201704.xyz
- `Set-ScoopConfig` - Configure Scoop settings and mirrors
- `Add-ScoopCNBucket` - Add the scoop-cn bucket
- `Update-ExistingApps` - Update existing app references
- `Show-PostInstallInfo` - Display post-installation summary
