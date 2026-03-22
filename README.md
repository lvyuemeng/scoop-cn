<div align="center">

# Scoop Buckets Mirrors

**[中文](README-cn.md) | [English](README.md)**

![GitHub Actions Workflow Status](https://github.com/lvyuemeng/scoop-cn/actions/workflows/auto-update.yml/badge.svg)

</div>

## Motivation

Scoop is a powerful and lightweight Windows package manager that simplifies software installation. However, users in regions with network restrictions (particularly in China) often encounter difficulties downloading packages from GitHub and other external sources.

This project provides mirrored bucket repositories with optimized download URLs, making it seamless to install and manage packages even behind network firewalls.

**If you don't experience any download issues with Scoop**, you may not need to use this project.

## Features

- **Aggregated Buckets**: Includes mirrors for `main extras versions nirsoft sysinternals php nerd-fonts nonportable java games`
- **Automatic Updates**: Mirrors are refreshed every 4 hours
- **Proxy Support**: Built-in support for Chinese proxy mirrors
- **Easy Migration**: Tools to migrate existing installations to use mirrored buckets

## Usage

### Quick Start

Once Scoop is installed, you can start using this bucket immediately:

```powershell
# Add the bucket
scoop bucket add spc https://gh-proxy.org/https://github.com/lvyuemeng/scoop-cn

# Search for packages
scoop search <package-name>

# Install packages
scoop install spc/<package-name>
```

### Migrate Existing Apps

If you already have apps installed through other buckets, you can migrate them to use our mirrors:

```powershell
# Migrate all installed apps to use the spc bucket
Get-ChildItem -Path "$env:USERPROFILE\scoop\apps" -Recurse -Filter "install.json" | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    if ($content -match '"bucket":\s*"(main|extras|versions|nirsoft|sysinternals|php|nerd-fonts|nonportable|java|games)"') {
        $content -replace '"bucket":\s*"(main|extras|versions|nirsoft|sysinternals|php|nerd-fonts|nonportable|java|games)"', '"bucket": "spc"' |
            Set-Content $_.FullName -Force
    }
}
```

### Configure Upstream Mirrors

You can also point existing Scoop buckets at proxy mirrors:

```powershell
# Change Scoop core repository upstream
scoop config SCOOP_REPO https://gitee.com/scoop-installer/scoop

# Change Main bucket upstream
git -C "$env:USERPROFILE\scoop\buckets\main" remote set-url origin https://gh-proxy.org/https://github.com/ScoopInstaller/Main

# Change scoop-cn bucket upstream
git -C "$env:USERPROFILE\scoop\buckets\spc" remote set-url origin https://gh-proxy.org/https://github.com/lvyuemeng/scoop-cn
```

## Installation

### Prerequisites

- **PowerShell** 5.1 or higher
- **Execution Policy** must allow script execution

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Method 1: Automated Installation (Recommended)

Use the provided `installer.ps1` script for a fully automated setup:

```powershell
# Download the installer
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/lvyuemeng/scoop-cn/main/installer.ps1" -OutFile "$env:TEMP\installer.ps1"

# Run with default settings (will prompt for proxy usage)
& "$env:TEMP\installer.ps1"

# Use Chinese proxy mirrors automatically
& "$env:TEMP\installer.ps1" -UseProxy

# Use proxy with a custom bucket name
& "$env:TEMP\installer.ps1" -UseProxy -BucketName my-bucket
```

#### Installer Parameters

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `-UseProxy` | Use Chinese proxy mirrors for installation | Prompt user |
| `-ScoopDir` | Custom Scoop installation directory | `$env:USERPROFILE\scoop` |
| `-BucketName` | Alias for the scoop-cn bucket | `spc` |

### Method 2: Manual Installation

```powershell
# Users with direct internet access
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression

# Users behind network restrictions (China)
$tmp = "$env:TEMP\scoop-install.ps1"
Invoke-WebRequest -Uri https://scoop.201704.xyz -OutFile $tmp
& $tmp
Remove-Item $tmp -Force
```

After installation, add the bucket:

```powershell
scoop bucket add spc https://gh-proxy.org/https://github.com/lvyuemeng/scoop-cn
```

## Configuration

For details about URL replacement rules see [`bin/config.ps1`](./bin/config.ps1).

## Contributing

Contributions are welcome! Please read our [contributing guidelines](CONTRIBUTING.md) before submitting changes.

### Ways to Contribute

- **Add New Mirror Rules**: Help us cover more packages with proxy support
- **Bug Fixes**: Improve existing URL replacement rules
- **Documentation**: Enhance guides and examples
- **Testing**: Add test coverage for new rules

### Testing

Run the test suite before submitting:

```powershell
.\tests\Run-Tests.ps1
```

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=lvyuemeng/scoop-cn&type=date&legend=top-left)](https://www.star-history.com/#lvyuemeng/scoop-cn&type=date&legend=top-left)
