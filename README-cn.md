<div align="center">

# Scoop Buckets Mirrors 

**[中文](README-cn.md) | [English](README.md)**

![GitHub Actions Workflow Status](https://github.com/lvyuemeng/scoop-cn/actions/workflows/auto-update.yml/badge.svg)

</div>

**特别感谢 `https://github.com/duzyn/scoop-cn`**，该项目原作者似乎已不再维护。

## 动机

Scoop 是一个优秀的包管理器，它简洁易用。然而，Scoop及其buckets的安装会阻碍那些受网络限制（特别是中国）的用户。因此，镜像是必要的，但手动替换每个软件源的链接过于麻烦，所以我创建（沿袭 `duzyn/scoop-cn`）了该仓库。

**如果你在使用 Scoop 及其软件包安装时没有下载问题**，则**不必**使用它。

## 简介

为了解决这个问题，我们替换至镜像链接，并通过变量代换的方式进行便捷替换。具体请查看[镜像配置](./bin/config.ps1)

### 特性：

- 涵盖的软件源：`main extras versions nirsoft sysinternals php nerd-fonts nonportable java games`。欢迎提交拉取请求，添加更多需要镜像的软件源。
- 每 4 小时更新一次。

## 安装

### 前提

[PowerShell](https://learn.microsoft.com/en-us/powershell/) 需具备 `>= 5.1` 版本， 所有Windows使用者应当对此并不陌生。否则，您需要参考 [PowerShell Installation Tutorial](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.5)。

```powershell
$PSVersionTable.PSVersion.Major >= 5.1
```

其次，您应该更改 `ExecutionPolicy` 以执行脚本。

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Scoop

您应该已经安装了 Scoop，如果没有，请阅读该节；如果已经安装，请跳至 `Buckets` 节。

- 请注意您的 scoop 安装路径。我们使用 `$env:USERPROFILE\scoop\` 作为默认路径。
- 请注意您添加的镜像源名称。我们使用 `spc` 作为默认名称。
- 如果您使用了自定义名称或路径，请自行修改相应配置。

在你的 Powershell 中，输入以下命令来下载并执行 Scoop 的安装。

```powershell
Invoke-WebRequest https://gh-proxy.com/https://raw.githubusercontent.com/ScoopInstaller/Install/master/install.ps1 | Invoke-Expression # 适用于受网络限制的用户

Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression # 适用于原生用户
```

这仅会下载带有镜像的安装脚本。然后，您还需要修改配置和软件源。

### Buckets

- 添加我们的软件源：

```powershell
scoop bucket add spc https://gh-proxy.com/https://github.com/lvyuemeng/scoop-cn # 你可以将 `spc` 改成其他名称，如果修改，则下方的 `spc` 也需修改。
```

- 更改你已安装的应用以解析到我们的软件源。每个 `<scoop-dir>\apps\<app>\current\install.json` 文件都可以修改以解析到我们的软件源。

```powershell
Get-ChildItem -Path "$env:USERPROFILE\scoop\apps" -Recurse -Filter "install.json" | ForEach-Object { (Get-Content -Path $_.FullName -Raw) -replace '"bucket": "(main|extras|versions|nirsoft|sysinternals|php|nerd-fonts|nonportable|java|games)"', '"bucket": "spc"' | Set-Content -Path $_.FullName }
```

- 检查我们的修改：

```powershell
Installed apps:

Name          Version           Source         Updated               Info
----          -------           ------         -------               ----
7zip          24.08             main           ...
git           2.47.0.2          main           ...
```

运行命令替换之后变为：

```powershell
Installed apps:

Name          Version           Source         Updated               Info
----          -------           ------         -------               ----
7zip          24.08             spc            ...
git           2.47.0.2          spc            ...
```

### 其他软件源（可选）

如果您想修改其他 Scoop 软件源的**上游链接**（用于同步远程仓库的链接），您可以通过以下命令更改，请注意您**需要安装`git`**：

```powershell
scoop config scoop_repo https://gh-proxy.com/https://github.com/ScoopInstaller/Scoop # 修改scoop拉取源
git -C "$env:USERPROFILE\scoop\buckets\main" remote set-url origin https://gh-proxy.com/https://github.com/ScoopInstaller/Main # 修改Main镜像源
git -C "$env:USERPROFILE\scoop\buckets\scoop-cn" remote set-url origin https://gh-proxy.com/https://github.com/duzyn/scoop-cn #修改scoop-cn镜像源
# 其他...
```

## Star 历史

[![Star History Chart](https://api.star-history.com/svg?repos=lvyuemeng/scoop-cn&type=date&legend=top-left)](https://www.star-history.com/#lvyuemeng/scoop-cn&type=date&legend=top-left)