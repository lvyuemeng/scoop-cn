#Requires -Module Pester

<#
.SYNOPSIS
    Tests for GitHub Actions workflow validation
#>

BeforeAll {
    $script:WorkflowsDir = Join-Path $PSScriptRoot ".." ".." ".github" "workflows"
}

Describe "Workflow File Structure" {
    It "Should have auto-update.yml" {
        $path = Join-Path $script:WorkflowsDir "auto-update.yml"
        Test-Path $path | Should -Be $true
    }

    It "Should have codeberg.yml" {
        $path = Join-Path $script:WorkflowsDir "codeberg.yml"
        Test-Path $path | Should -Be $true
    }
}

Describe "Auto-Update Workflow" {
    BeforeAll {
        $path = Join-Path $script:WorkflowsDir "auto-update.yml"
        $script:AutoUpdateContent = Get-Content $path -Raw
    }

    It "Should NOT use force push" {
        $script:AutoUpdateContent | Should -Not -Match 'git\s+push\s+-f'
        $script:AutoUpdateContent | Should -Not -Match 'git\s+push\s+--force'
    }

    It "Should have concurrency control" {
        $script:AutoUpdateContent | Should -Match 'concurrency:'
    }
}
