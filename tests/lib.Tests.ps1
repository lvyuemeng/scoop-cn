#Requires -Module Pester

<#
.SYNOPSIS
    Tests for bin/lib.ps1 functions
#>

BeforeAll {
    # Import the library
    $script:BinRoot = Join-Path $PSScriptRoot ".." "bin"
    . (Join-Path $script:BinRoot "lib.ps1")
}

Describe "Expand-Variables" {
    It "Should expand single variable" {
        $vars = @{ Github = "https://proxy.com" }
        $result = Expand-Variables -text '${Github}/url' -vars $vars
        $result | Should -Be "https://proxy.com/url"
    }

    It "Should expand multiple variables" {
        $vars = @{
            Github   = "https://gh-proxy.org"
            Tsinghua = "mirrors.tuna.tsinghua.edu.cn"
        }
        $result = Expand-Variables -text '${Github}/path and ${Tsinghua}/other' -vars $vars
        $result | Should -Be "https://gh-proxy.org/path and mirrors.tuna.tsinghua.edu.cn/other"
    }

    It "Should handle recursive expansion" {
        $vars = @{
            Proxy  = '${Mirror}'
            Mirror = 'https://mirror.com'
        }
        $result = Expand-Variables -text '${Proxy}/path' -vars $vars
        $result | Should -Be "https://mirror.com/path"
    }
}

Describe "Update-Manifest" {
    BeforeEach {
        $script:TestDir = Join-Path $TestDrive "bucket"
        if (Test-Path $script:TestDir) {
            Remove-Item -Path $script:TestDir -Recurse -Force
        }
        New-Item -ItemType Directory -Path $script:TestDir | Out-Null
        $script:JsonValidationFailures = 0
    }

    It "Should apply replacement rules" {
        $manifestPath = Join-Path $script:TestDir "test.json"
        '{"url": "https://github.com/user/repo"}' | Set-Content $manifestPath

        $rules = @(
            @{
                description = "Test rule"
                find        = 'github\.com'
                replace     = 'proxy.com/github'
            }
        )

        Update-Manifest -manifest (Get-Item $manifestPath) -rules $rules -vars @{}

        $content = Get-Content $manifestPath -Raw
        $content | Should -Match "proxy.com/github"
    }

    It "Should validate JSON and reject invalid output" {
        $manifestPath = Join-Path $script:TestDir "test.json"
        '{"url": "https://github.com/user/repo"}' | Set-Content $manifestPath
        $originalContent = Get-Content $manifestPath -Raw

        $rules = @(
            @{
                description = "Break JSON"
                find        = '"url"'
                replace     = '"url": invalid'  # This breaks JSON syntax
            }
        )

        # Capture errors to verify validation worked
        $errorCountBefore = $global:JsonValidationFailures
        { Update-Manifest -manifest (Get-Item $manifestPath) -rules $rules -vars @{} -ErrorAction SilentlyContinue } | Should -Not -Throw

        $content = Get-Content $manifestPath -Raw
        $content | Should -Be $originalContent  # Should remain unchanged
        # The variable in lib.ps1 should have been incremented
        $global:JsonValidationFailures | Should -BeGreaterThan $errorCountBefore
    }

    It "Should write files without BOM" {
        $manifestPath = Join-Path $script:TestDir "test.json"
        '{"test": "value"}' | Set-Content $manifestPath

        $rules = @(
            @{
                description = "Test rule"
                find        = 'value'
                replace     = 'changed'
            }
        )

        Update-Manifest -manifest (Get-Item $manifestPath) -rules $rules -vars @{}

        $bytes = [System.IO.File]::ReadAllBytes($manifestPath)
        $hasBom = ($bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF)
        $hasBom | Should -Be $false
    }
}

Describe "Invoke-BucketAggregation" {
    It "Should be defined" {
        Get-Command Invoke-BucketAggregation | Should -Not -BeNullOrEmpty
    }
}
