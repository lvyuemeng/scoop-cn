<div align="center">

# Scoop Buckets Mirrors 

**[中文](README-cn.md) | [English](README.md)**

![GitHub Actions Workflow Status](https://github.com/lvyuemeng/scoop-cn/actions/workflows/auto-update.yml/badge.svg)

</div>

**Especially thanks to `https://github.com/duzyn/scoop-cn`** which currently seems not maintained now.

## Why I create

Scoop is a great package manager which is easy and simple. However, the downloads urls of itself, buckets, packages will impede those who are behind walls(Especially **Chinese**). Thus proxy is necessary but hard to tackle by manually replacing each urls of buckets.

Therefore I create (follows from `duzyn/scoop-cn`) the proxy-oriented buckets.

**If you don't have the downloads problem for scoop and its package installation**, you don't **have to** use it.

## Introduction

In order to solve the problem, we replace urls by mirror one with variables replacement. To check the concrete replacement, please check [config](./bin/config.ps1)

### Features:

- The buckets of repo：`main extras versions nirsoft sysinternals php nerd-fonts nonportable java games`. You are welcome to pull request for more buckets needing mirrors.
- Updated per 4 hours.

## Installation

### Prerequisite

[PowerShell](https://learn.microsoft.com/en-us/powershell/) Should be `>= 5.1`, which should be common for every windows user. Otherwise you have to refer [PowerShell Installation Tutorial](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.5).

```powershell
$PSVersionTable.PSVersion.Major >= 5.1
```

Second, you should change the `ExecutionPolicy` to execute scripts.

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Scoop

You should have scoop already, if not, watch below, if so, skip to `Buckets` section.

- Please notice to your scoop installation location. We use `$env:USERPROFILE\scoop\` as the default location.
- Please notice the bucket name you added. We use `spc` as the default name.
- If you use custom name or path, please modify your own.

In your Powershell, input below commands to download and execute installation of scoop.

```powershell
Invoke-WebRequest https://gh-proxy.com/https://raw.githubusercontent.com/ScoopInstaller/Install/master/install.ps1 | Invoke-Expression # For user behind walls

Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression # For native user
```

It only downloads installation script with mirrors. Then, you need to modify the configuration and bucket too.

### Buckets

- Add our bucket:

```powershell
scoop bucket add spc https://gh-proxy.com/https://github.com/lvyuemeng/scoop-cn # You can change `spc` to other name, if so, modify below name `spc` too.
```

- Change your installed apps to resolve our bucket. Each `<scoop-dir>\apps\<app>\current\install.json` could be modified to resolve our bucket.

```powershell
Get-ChildItem -Path "$env:USERPROFILE\scoop\apps" -Recurse -Filter "install.json" | ForEach-Object { (Get-Content -Path $_.FullName -Raw) -replace '"bucket": "(main|extras|versions|nirsoft|sysinternals|php|nerd-fonts|nonportable|java|games)"', '"bucket": "spc"' | Set-Content -Path $_.FullName }
```

- Check our modification:

```powershell
Installed apps:

Name          Version           Source         Updated               Info
----          -------           ------         -------               ----
7zip          24.08             main           ...
git           2.47.0.2          main           ...
```

Change to:

```powershell
Installed apps:

Name          Version           Source         Updated               Info
----          -------           ------         -------               ----
7zip          24.08             spc            ...
git           2.47.0.2          spc            ...
```

### Other Buckets(Optional)

If you want to modify your other scoop bucket upstream url (Which is the url your bucket to synchronize the remote one.), you could change by below commands, notice you **should have `git`**:

```powershell
scoop config scoop_repo https://gh-proxy.com/https://github.com/ScoopInstaller/Scoop # Change Scoop upstream
git -C "$env:USERPROFILE\scoop\buckets\main" remote set-url origin https://gh-proxy.com/https://github.com/ScoopInstaller/Main # Change Main bucket upstream
git -C "$env:USERPROFILE\scoop\buckets\scoop-cn" remote set-url origin https://gh-proxy.com/https://github.com/duzyn/scoop-cn # Change scoop-cn bucket upstream
# Others...
```

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=lvyuemeng/scoop-cn&type=date&legend=top-left)](https://www.star-history.com/#lvyuemeng/scoop-cn&type=date&legend=top-left)
