[PowerShell](https://learn.microsoft.com/zh-cn/powershell/) 版本在 5.1 或以上，如果没有 PowerShell 大于 5.1 版本，可以下载安装 [PowerShell Core](https://github.com/PowerShell/PowerShell)。运行以下命令查看：
# Scoop Proxy

**特别感谢 `https://github.com/duzyn/scoop-cn`**，该项目原作者似乎已不再维护。

## 动机

Scoop 是一个优秀的包管理器，它简洁易用。然而，Scoop及其buckets的安装会阻碍那些受网络限制（特别是中国）的用户。因此，镜像是必要的，但手动替换每个软件源的链接过于麻烦，所以我创建（沿袭 `duzyn/scoop-cn`）了该仓库。

**如果你在使用 Scoop 及其软件包安装时没有下载问题**，则**不必**使用它。

## 简介

为了解决这个问题，我们替换了镜像链接：[Github Proxy](https://gh-proxy.com/)。

### 特性：

  - 涵盖的软件源：`main extras versions nirsoft sysinternals php nerd-fonts nonportable java games`。欢迎提交拉取请求，添加更多需要代理的软件源。
  - 每 4 小时更新一次。

## 安装

### 先决条件

[PowerShell](https://learn.microsoft.com/en-us/powershell/) 需具备 `>= 5.1` 版本， 所有Windows使用者应当不陌生。否则，您需要安装 [PowerShell Core](https://github.com/PowerShell/PowerShell)。

```powershell
$PSVersionTable.PSVersion.Major >= 5.1
```

其次，您应该更改 `ExecutionPolicy` 以执行脚本。

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Scoop

您应该已经安装了 Scoop，如果没有，请阅读该节；如果已经安装，请跳至 `Buckets` 节。

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

路径 `$env:USERPROFILE\scoop\apps` 应根据您的安装位置进行修改，如果您更改安装位置，请一并修改此路径；名称 `spc` 也应根据您之前添加的软件源名称进行修改，如果更改，请一并修改此名称。

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

如果您想修改其他 Scoop 软件源的**上游链接**（用于同步远程仓库的链接），您可以通过以下命令更改，请注意您**应该安装`git`**：

```powershell
scoop config scoop_repo https://gh-proxy.com/https://github.com/ScoopInstaller/Scoop
git -C "$env:USERPROFILE\scoop\buckets\main" remote set-url origin https://gh-proxy.com/https://github.com/ScoopInstaller/Main
git -C "$env:USERPROFILE\scoop\buckets\scoop-cn" remote set-url origin https://gh-proxy.com/https://github.com/duzyn/scoop-cn
# 还有其他的...
```

## 使用方法

```powershell
scoop search <app-name>
scoop install <app-name>
scoop install spc/<app-name>
scoop help
```

## Star 历史

![Star History Chart](https://api.star-history.com/svg?repos=lvyuemeng/scoop-cn&type=Date)