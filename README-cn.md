<div align="center">

# Scoop Buckets Mirrors

**[中文](README-cn.md) | [English](README.md)**

![GitHub Actions Workflow Status](https://github.com/lvyuemeng/scoop-cn/actions/workflows/auto-update.yml/badge.svg)

</div>

## 动机

Scoop 是一个功能强大且轻量级的 Windows 包管理工具，能简化软件的安装和管理流程。然而，由于网络限制，从 GitHub 等外部源下载软件包时常常遇到困难。

本项目提供经过优化的镜像软件源，使用经过替换的下载链接，让您即使在网络受限的环境下也能顺畅地安装和管理软件包。

**如果您在使用 Scoop 时没有遇到任何下载问题**，则不一定需要使用本项目。

## 特性

- **聚合软件源**：涵盖 `main extras versions nirsoft sysinternals php nerd-fonts nonportable java games` 的镜像
- **自动更新**：镜像每 4 小时刷新一次
- **代理支持**：内置中国代理镜像支持
- **轻松迁移**：提供工具将现有安装迁移至镜像源

## 使用方法

### 快速开始

安装 Scoop 后，您可以立即使用本软件源：

```powershell
# 添加软件源
scoop bucket add spc https://gh-proxy.com/https://github.com/lvyuemeng/scoop-cn

# 搜索软件包
scoop search <软件包名称>

# 安装软件包
scoop install spc/<软件包名称>
```

### 迁移现有应用

如果您已经通过其他软件源安装了应用，可以将其迁移至本镜像：

```powershell
# 将所有已安装的应用迁移至 spc 软件源
Get-ChildItem -Path "$env:USERPROFILE\scoop\apps" -Recurse -Filter "install.json" | ForEach-Object { (Get-Content -Path $_.FullName -Raw) -replace '"bucket": "(main|extras|versions|nirsoft|sysinternals|php|nerd-fonts|nonportable|java|games)"', '"bucket": "spc"' | Set-Content -Path $_.FullName }
```

### 配置上游镜像

您还可以配置其他 Scoop 软件源的上游链接使用镜像：

```powershell
# 修改 Scoop 核心仓库上游
scoop config scoop_repo https://gh-proxy.com/https://github.com/ScoopInstaller/Scoop

# 修改 Main 软件源上游
git -C "$env:USERPROFILE\scoop\buckets\main" remote set-url origin https://gh-proxy.com/https://github.com/ScoopInstaller/Main

# 修改 scoop-cn 软件源上游
git -C "$env:USERPROFILE\scoop\buckets\scoop-cn" remote set-url origin https://gh-proxy.com/https://github.com/duzyn/scoop-cn
```

## 安装

### 前提条件

在安装 Scoop 之前，请确保您的系统满足以下要求：

- **PowerShell**：版本 5.1 或更高

```powershell
$PSVersionTable.PSVersion.Major >= 5.1
```

- **执行策略**：必须允许脚本执行

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### 方法一：自动化安装（推荐）

使用提供的 `installer.ps1` 脚本进行全自动安装：

```powershell
# 下载安装脚本
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/lvyuemeng/scoop-cn/master/installer.ps1" -OutFile "$env:TEMP\installer.ps1"

# 使用默认设置运行（会提示是否使用代理）
& "$env:TEMP\installer.ps1"

# 或直接指定选项：
# 自动使用中国代理镜像
& "$env:TEMP\installer.ps1" -UseProxy

# 使用代理并自定义软件源名称
& "$env:TEMP\installer.ps1" -UseProxy -BucketName "my-bucket"
```

#### 安装脚本参数

| 参数 | 说明 | 默认值 |
| ---- | ---- | ------ |
| `-UseProxy` | 使用中国代理镜像进行安装 | 提示用户选择 |
| `-ScoopDir` | 自定义 Scoop 安装目录 | `$env:USERPROFILE\scoop` |
| `-BucketName` | scoop-cn 软件源名称 | `spc` |

### 方法二：手动安装

如果您更喜欢手动安装：

```powershell
# 适用于受网络限制的用户（中国大陆）
Invoke-WebRequest https://gh-proxy.com/https://raw.githubusercontent.com/ScoopInstaller/Install/master/install.ps1 | Invoke-Expression

# 适用于网络正常的用户
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
```

安装后，添加本软件源：

```powershell
scoop bucket add spc https://gh-proxy.com/https://github.com/lvyuemeng/scoop-cn
```

## 配置

有关 URL 替换规则的更多详细信息，请参阅[配置文件](./bin/config.ps1)。

## 贡献

欢迎贡献代码！提交更改前请阅读我们的[贡献指南](CONTRIBUTING.md)。

### 贡献方式

- **添加新的镜像规则**：帮助我们覆盖更多需要代理支持的软件包
- **错误修复**：改进现有的 URL 替换规则
- **文档**：完善指南和示例
- **测试**：为新规则添加测试覆盖

### 测试

提交前请运行测试套件：

```powershell
.\tests\Run-Tests.ps1
```

## 许可证

本项目基于 MIT 许可证授权 - 请参阅 [LICENSE](LICENSE) 文件了解详情。

## Star 历史

[![Star History Chart](https://api.star-history.com/svg?repos=lvyuemeng/scoop-cn&type=date&legend=top-left)](https://www.star-history.com/#lvyuemeng/scoop-cn&type=date&legend=top-left)
