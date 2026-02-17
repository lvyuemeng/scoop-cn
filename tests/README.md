# Scoop-CN Test Suite

This directory contains the Pester-based test suite for scoop-cn.

## Running Tests

```powershell
# Run all tests
Invoke-Pester tests/

# Run specific test file
Invoke-Pester tests/lib.Tests.ps1

# Run with verbose output
Invoke-Pester tests/ -Verbose
```

## Test Structure

- `lib.Tests.ps1` - Tests for bin/lib.ps1 functions
- `config.Tests.ps1` - Tests for bin/config.ps1 rules
- `workflows/` - Workflow validation tests
