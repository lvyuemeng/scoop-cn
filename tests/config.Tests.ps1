#Requires -Module Pester

<#
.SYNOPSIS
    Tests for bin/config.ps1 rules
#>

BeforeAll {
    $script:ConfigPath = Join-Path $PSScriptRoot ".." "bin" "config.ps1"
    $script:Config = & $script:ConfigPath
}

Describe "Config Structure" {
    It "Should have repositories array" {
        $script:Config.repositories | Should -Not -BeNullOrEmpty
        $script:Config.repositories.Count | Should -BeGreaterThan 0
    }

    It "Should have proxies hashtable" {
        $script:Config.proxies | Should -Not -BeNullOrEmpty
        $script:Config.proxies.Github | Should -Not -BeNullOrEmpty
    }

    It "Should have rules array" {
        $script:Config.rules | Should -Not -BeNullOrEmpty
        $script:Config.rules.Count | Should -BeGreaterThan 0
    }
}

Describe "Hardcoded Bucket Name Rules" {
    It "Should have scripts path rule disabled" {
        $rule = $script:Config.rules | Where-Object { $_.description -like "*scripts*" }
        $rule | Should -Not -BeNullOrEmpty
        $rule.enabled | Should -Be $false
    }

    It "Should have suggest rule disabled" {
        $rule = $script:Config.rules | Where-Object { $_.description -like "*suggest*" }
        $rule | Should -Not -BeNullOrEmpty
        $rule.enabled | Should -Be $false
    }

    It "Should have depends rule disabled" {
        $rule = $script:Config.rules | Where-Object { $_.description -like "*depends*" }
        $rule | Should -Not -BeNullOrEmpty
        $rule.enabled | Should -Be $false
    }
}

Describe "Cygwin Regex Rule" {
    It "Should have Cygwin rule enabled" {
        $rule = $script:Config.rules | Where-Object { $_.description -like "*Cygwin*" }
        $rule | Should -Not -BeNullOrEmpty
        $rule.enabled | Should -Be $true
    }

    It "Should match cygwin.com URLs" {
        $rule = $script:Config.rules | Where-Object { $_.description -like "*Cygwin*" }
        'http://cygwin.com/packages' | Should -Match $rule.find
        'https://www.cygwin.com/mirror' | Should -Match $rule.find
    }

    It "Should NOT match other domains with cygwin in path" {
        $rule = $script:Config.rules | Where-Object { $_.description -like "*Cygwin*" }
        'http://example.com/cygwin/mirror' | Should -Not -Match $rule.find
        'https://other.com/path/cygwin/' | Should -Not -Match $rule.find
    }
}

Describe "7-Zip Rules" {
    It "Should have 7-Zip main rule" {
        $rule = $script:Config.rules | Where-Object { $_.description -eq "Proxy: 7-Zip (to GitHub Releases)" }
        $rule | Should -Not -BeNullOrEmpty
        $rule.enabled | Should -Be $true
    }

    It "Should have 7zr.exe rule" {
        $rule = $script:Config.rules | Where-Object { $_.description -like "*7zr.exe*" }
        $rule | Should -Not -BeNullOrEmpty
        $rule.enabled | Should -Be $true
    }

    It "Should match 7zr.exe URL" {
        $rule = $script:Config.rules | Where-Object { $_.description -like "*7zr.exe*" }
        'https://www.7-zip.org/a/7zr.exe' | Should -Match $rule.find
    }
}

Describe "URL Replacement Rules" {
    It "Should have GitHub Releases rule" {
        $rule = $script:Config.rules | Where-Object { $_.description -eq "Proxy: GitHub Releases Download" }
        $rule | Should -Not -BeNullOrEmpty
        $rule.enabled | Should -Be $true
    }

    It "Should match GitHub releases URLs" {
        $rule = $script:Config.rules | Where-Object { $_.description -eq "Proxy: GitHub Releases Download" }
        'https://github.com/user/repo/releases/download/v1.0/file.zip' | Should -Match $rule.find
    }
}
