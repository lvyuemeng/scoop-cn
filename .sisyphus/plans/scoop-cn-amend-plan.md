# Scoop-CN Amend Plan

## TL;DR

> **Objective**: Fix all 14 defects identified in the codebase inspection report, with critical priority on hardcoded bucket names and atomic updates.
> 
> **Deliverables**: 
> - Fixed aggregation script with atomic updates and error handling
> - Corrected replacement rules (no hardcoded bucket names)
> - Enhanced CI/CD workflows (testing, concurrency, security)
> - Validation and safety mechanisms (JSON validation, BOM handling)
> - Updated documentation
> 
> **Estimated Effort**: Large (20-30 tasks across 4 waves)
> **Parallel Execution**: YES - 4 waves with 5-8 tasks per wave
> **Critical Path**: Script fixes → Workflow fixes → Validation → Documentation

---

## Context

### Original Request
Fix all 14 defects identified in the Scoop-CN codebase inspection report.

### Project Overview
**scoop-cn** is a Scoop bucket mirror project that:
- Aggregates 10 upstream Scoop buckets
- Replaces download URLs with Chinese mirror/proxy URLs
- Serves Chinese users behind network restrictions

### Codebase Structure
```
scoop-cn/
├── bin/
│   ├── auto-update.ps1      # Entry point (8 lines)
│   ├── lib.ps1              # Core logic (158 lines)
│   └── config.ps1           # Repositories, proxies, rules (210 lines)
├── bucket/                  # 6183 JSON manifest files
├── scripts/                 # 22 PowerShell helper scripts
├── .github/workflows/
│   ├── auto-update.yml      # Main CI workflow (40 lines)
│   └── codeberg.yml         # Mirror workflow (24 lines)
└── docs/
    └── inspect.md           # This inspection report
```

### Defect Summary

| # | Defect | Severity | Category | Location |
|---|--------|----------|----------|----------|
| 1 | Hardcoded bucket name in scripts | **Critical** | Design | `config.ps1:193-195` |
| 2 | Fixed bucket name in dependencies | **Critical** | Design | `config.ps1:198-208` |
| 3 | Force push in CI/CD | High | Workflow | `auto-update.yml:38` |
| 4 | No atomic updates | **Critical** | Design | `lib.ps1:69-72` |
| 5 | Missing git error handling | Medium | Logic | `lib.ps1:80` |
| 6 | Overly broad regex | Medium | Logic | `config.ps1:97-99` |
| 7 | Incomplete URL replacement | Medium | Logic | `bucket/7zip.json:26` |
| 8 | No JSON validation | Medium | Logic | `lib.ps1:35-57` |
| 9 | BOM encoding issues | Low | Quality | Multiple files |
| 10 | Missing concurrency control | Medium | Workflow | `auto-update.yml` |
| 11 | No testing stage | High | Workflow | `auto-update.yml` |
| 12 | SSH verification disabled | Medium | Security | `codeberg.yml:23` |
| 13 | Outdated references | Low | Documentation | `README.md:11,107` |
| 14 | Missing config docs | Low | Documentation | N/A |

---

## Work Objectives

### Core Objective
Fix all 14 defects in the scoop-cn codebase to improve reliability, security, and user experience.

### Concrete Deliverables
1. **bin/lib.ps1** - Atomic updates, git error handling, JSON validation
2. **bin/config.ps1** - Remove hardcoded bucket names, fix regex rules
3. **.github/workflows/auto-update.yml** - Add testing, concurrency control, remove force push
4. **.github/workflows/codeberg.yml** - Enable SSH verification
5. **README.md** - Update outdated references, add configuration documentation

### Definition of Done
- [ ] All 14 defects are addressed
- [ ] CI/CD workflows pass validation
- [ ] Manifest generation produces valid JSON
- [ ] Documentation is accurate and complete

### Must Have
- Atomic update mechanism (no data loss on failure)
- Git operation error handling
- JSON validation after URL replacement
- CI/CD testing stage

### Must NOT Have
- Hardcoded bucket names in generated manifests
- Force push in CI/CD
- Disabled SSH verification
- Untested changes being committed

---

## Verification Strategy

### Test Infrastructure
- **Infrastructure exists**: NO (needs setup)
- **Automated tests**: Tests-after implementation
- **Framework**: PowerShell Pester (native PowerShell testing)

### QA Policy
Every task includes agent-executed QA scenarios:

| Deliverable Type | Verification Tool | Method |
|------------------|-------------------|--------|
| PowerShell scripts | Bash (PowerShell execution) | Run functions, validate output |
| CI/CD workflows | Bash (act or manual validation) | Validate YAML syntax |
| JSON manifests | Bash (jq) | Validate JSON structure |
| Documentation | Bash (markdown lint) | Check formatting |

---

## Execution Strategy

### Parallel Execution Waves

```
Wave 1 (Foundation - Script Core Fixes):
├── Task 1: Fix atomic updates in lib.ps1 [deep]
├── Task 2: Add git error handling [quick]
├── Task 3: Add JSON validation [quick]
└── Task 4: Fix BOM encoding issues [quick]

Wave 2 (Configuration - Rules & Safety):
├── Task 5: Fix hardcoded bucket name (scripts path) [deep]
├── Task 6: Fix hardcoded bucket name (dependencies) [deep]
├── Task 7: Fix overly broad Cygwin regex [quick]
├── Task 8: Fix incomplete URL replacement (7zip) [quick]
└── Task 9: Add test infrastructure setup [quick]

Wave 3 (CI/CD - Workflow Improvements):
├── Task 10: Remove force push from auto-update [quick]
├── Task 11: Add concurrency control [quick]
├── Task 12: Add testing stage to workflow [unspecified-high]
├── Task 13: Enable SSH verification in codeberg [quick]
└── Task 14: Add workflow validation tests [quick]

Wave 4 (Documentation & Polish):
├── Task 15: Update outdated references in README [writing]
├── Task 16: Add configuration documentation [writing]
├── Task 17: Create comprehensive test suite [unspecified-high]
└── Task 18: Create migration guide for users [writing]

Wave FINAL (Verification - All Parallel):
├── Task F1: Full integration test [deep]
├── Task F2: Code quality review [unspecified-high]
├── Task F3: Documentation review [writing]
└── Task F4: End-to-end workflow test [unspecified-high]

Critical Path: T1 → T5/T6 → T10 → T12 → T17 → F1-F4
Parallel Speedup: ~60% faster than sequential
```

### Dependency Matrix

| Task | Depends On | Blocks | Wave |
|------|------------|--------|------|
| 1 | — | 2, 3, 4 | 1 |
| 2 | 1 | F1 | 1 |
| 3 | 1 | F1 | 1 |
| 4 | — | F1 | 1 |
| 5 | — | F1 | 2 |
| 6 | — | F1 | 2 |
| 7 | — | F1 | 2 |
| 8 | — | F1 | 2 |
| 9 | — | 14, 17 | 2 |
| 10 | — | F4 | 3 |
| 11 | — | F4 | 3 |
| 12 | 9 | F4 | 3 |
| 13 | — | F4 | 3 |
| 14 | 9 | F4 | 3 |
| 15 | — | F3 | 4 |
| 16 | — | F3 | 4 |
| 17 | 9 | F4 | 4 |
| 18 | 5, 6 | F3 | 4 |

---

## TODOs

### Wave 1: Script Core Fixes

#### Task 1: Implement Atomic Updates (Defect #4)

**What to do**:
- Modify `bin/lib.ps1` `Invoke-BucketAggregation` function
- Use temp directory pattern: clone to temp, validate, then swap
- Implement rollback on failure
- Preserve existing directory if new aggregation fails

**Must NOT do**:
- Delete existing bucket before validating new one
- Leave bucket in inconsistent state on error

**Recommended Agent Profile**:
- **Category**: `deep` - Complex logic changes with error handling
- **Skills**: None required

**Parallelization**:
- **Can Run In Parallel**: YES
- **Parallel Group**: Wave 1 (with Tasks 2, 3, 4)
- **Blocks**: Tasks 2, 3 (share lib.ps1 file)
- **Blocked By**: None

**References**:
- `bin/lib.ps1:60-94` - Current aggregation logic
- Pattern: Temp directory swap pattern from deployment best practices

**Acceptance Criteria**:

**QA Scenarios**:

```
Scenario: Atomic update succeeds
Tool: Bash (PowerShell)
Preconditions: bucket/ directory exists with manifests
Steps:
  1. Run Invoke-BucketAggregation with test repos
  2. Verify temp directory is created
  3. Verify old bucket is backed up
  4. Verify swap happens atomically
  5. Verify cleanup removes temp dirs
Expected Result: bucket/ contains new manifests, no temp dirs remain
Evidence: .sisyphus/evidence/task-1-atomic-success.log

Scenario: Atomic update fails mid-process
Tool: Bash (PowerShell)
Preconditions: bucket/ directory exists with valid manifests
Steps:
  1. Simulate git clone failure (invalid repo URL)
  2. Run Invoke-BucketAggregation
  3. Verify error is caught
  4. Verify original bucket/ is preserved
  5. Verify temp dirs are cleaned up
Expected Result: bucket/ unchanged, error message displayed, no data loss
Evidence: .sisyphus/evidence/task-1-atomic-failure.log
```

**Commit**: YES
- Message: `fix(lib): implement atomic updates with rollback`
- Files: `bin/lib.ps1`

---

#### Task 2: Add Git Error Handling (Defect #5)

**What to do**:
- Add try-catch around git clone operations in `bin/lib.ps1:80`
- Check git exit codes
- Log errors with context (which repo failed)
- Continue processing other repos if one fails (or fail fast - TBD)

**Must NOT do**:
- Silently ignore git failures
- Continue as if clone succeeded when it failed

**Recommended Agent Profile**:
- **Category**: `quick` - Straightforward error handling addition
- **Skills**: None required

**Parallelization**:
- **Can Run In Parallel**: YES (with Task 1, different parts of lib.ps1)
- **Parallel Group**: Wave 1
- **Blocks**: None
- **Blocked By**: None

**References**:
- `bin/lib.ps1:80` - Current git clone line
- PowerShell error handling patterns: `$?` and `$LASTEXITCODE`

**Acceptance Criteria**:

**QA Scenarios**:

```
Scenario: Git clone succeeds
Tool: Bash (PowerShell)
Preconditions: Valid git repo URL
Steps:
  1. Clone a valid repo
  2. Verify exit code 0
  3. Verify success message
Expected Result: Repo cloned, success logged
Evidence: .sisyphus/evidence/task-2-git-success.log

Scenario: Git clone fails
Tool: Bash (PowerShell)
Preconditions: Invalid git repo URL
Steps:
  1. Attempt clone of non-existent repo
  2. Verify error is caught
  3. Verify meaningful error message with repo name
  4. Verify process continues (if multi-repo) or stops cleanly
Expected Result: Error caught, meaningful message, no crash
Evidence: .sisyphus/evidence/task-2-git-failure.log
```

**Commit**: YES (group with Task 1)
- Message: `fix(lib): add git error handling`
- Files: `bin/lib.ps1`

---

#### Task 3: Add JSON Validation (Defect #8)

**What to do**:
- Add JSON validation after URL replacement in `bin/lib.ps1:35-57`
- Use `ConvertFrom-Json` with error handling
- If invalid, log error and preserve original file
- Track validation failures for reporting

**Must NOT do**:
- Write invalid JSON to manifest files
- Silently corrupt manifests

**Recommended Agent Profile**:
- **Category**: `quick` - Validation logic addition
- **Skills**: None required

**Parallelization**:
- **Can Run In Parallel**: YES
- **Parallel Group**: Wave 1
- **Blocks**: None
- **Blocked By**: None

**References**:
- `bin/lib.ps1:35-57` - Update-Manifest function
- PowerShell JSON validation: `ConvertFrom-Json` with try-catch

**Acceptance Criteria**:

**QA Scenarios**:

```
Scenario: Valid JSON after replacement
Tool: Bash (PowerShell)
Preconditions: Manifest with valid replacements
Steps:
  1. Apply valid URL replacement
  2. Run JSON validation
  3. Verify validation passes
  4. Verify file is written
Expected Result: JSON valid, file written
Evidence: .sisyphus/evidence/task-3-json-valid.log

Scenario: Invalid JSON after replacement (malformed regex)
Tool: Bash (PowerShell)
Preconditions: Manifest that would produce invalid JSON
Steps:
  1. Apply problematic regex replacement
  2. Run JSON validation
  3. Verify validation fails
  4. Verify original file is preserved
  5. Verify error is logged
Expected Result: Invalid JSON detected, original preserved, error logged
Evidence: .sisyphus/evidence/task-3-json-invalid.log
```

**Commit**: YES (group with Task 1)
- Message: `fix(lib): add JSON validation after replacement`
- Files: `bin/lib.ps1`

---

#### Task 4: Fix BOM Encoding Issues (Defect #9)

**What to do**:
- Ensure files are written without UTF-8 BOM
- Use `[Text.Encoding]::UTF8` (no BOM) instead of `UTF8Encoding` with BOM
- Check existing files for BOM and remove if present

**Must NOT do**:
- Add BOM to files
- Use default encoding that may include BOM

**Recommended Agent Profile**:
- **Category**: `quick` - Encoding fix
- **Skills**: None required

**Parallelization**:
- **Can Run In Parallel**: YES
- **Parallel Group**: Wave 1
- **Blocks**: None
- **Blocked By**: None

**References**:
- `bin/lib.ps1:56` - File write operation
- PowerShell encoding: `New-Object System.Text.UTF8Encoding($false)` for no BOM

**Acceptance Criteria**:

**QA Scenarios**:

```
Scenario: Files written without BOM
Tool: Bash (PowerShell)
Preconditions: Manifest file to write
Steps:
  1. Write manifest using updated function
  2. Read first 3 bytes
  3. Verify no BOM (should not be EF BB BF)
Expected Result: File starts with '{' not BOM bytes
Evidence: .sisyphus/evidence/task-4-bom-check.hex

Scenario: Existing BOM files cleaned
Tool: Bash (PowerShell)
Preconditions: Sample file with BOM
Steps:
  1. Create test file with BOM
  2. Run BOM removal
  3. Verify BOM removed
Expected Result: BOM removed, content preserved
Evidence: .sisyphus/evidence/task-4-bom-remove.log
```

**Commit**: YES (group with Task 1)
- Message: `fix(lib): write files without UTF-8 BOM`
- Files: `bin/lib.ps1`

---

### Wave 2: Configuration & Rules Fixes

#### Task 5: Fix Hardcoded Bucket Name - Scripts Path (Defect #1)

**What to do**:
- Modify `bin/config.ps1:193-195` rule "Fix: Internal 'scripts' paths"
- Change from hardcoded `scoop-cn` to use dynamic bucket resolution
- Options:
  a) Remove this rule entirely and let Scoop resolve paths naturally
  b) Use relative path pattern that works with any bucket name
  c) Use Scoop's `$bucket` variable in post_install scripts

**Recommended approach**: Option A - Remove the rule and update manifest templates to use relative paths like `"$PSScriptRoot\..\scripts\..."` or document that scripts must use `$bucketsdir\$bucket` pattern.

**Must NOT do**:
- Keep hardcoded `scoop-cn` in the replacement rule
- Break existing functionality that depends on scripts

**Recommended Agent Profile**:
- **Category**: `deep` - Architectural decision with implications
- **Skills**: None required

**Parallelization**:
- **Can Run In Parallel**: YES (with Task 6, different rules)
- **Parallel Group**: Wave 2
- **Blocks**: Task 18 (migration guide)
- **Blocked By**: None

**References**:
- `bin/config.ps1:192-196` - Current scripts path rule
- `bucket/7zip.json:35` - Example of hardcoded path (generated)
- Scoop documentation on `$bucket` variable

**Acceptance Criteria**:

**QA Scenarios**:

```
Scenario: Scripts path without hardcoded bucket name
Tool: Bash (PowerShell)
Preconditions: Sample manifest with post_install
Steps:
  1. Run aggregation with updated rules
  2. Check generated manifest post_install
  3. Verify no hardcoded bucket name in paths
  4. Verify scripts still resolve correctly
Expected Result: Paths are dynamic/resolvable regardless of bucket name
Evidence: .sisyphus/evidence/task-5-scripts-path.log
```

**Commit**: YES
- Message: `fix(config): remove hardcoded bucket name from scripts path rule`
- Files: `bin/config.ps1`

---

#### Task 6: Fix Hardcoded Bucket Name - Dependencies (Defect #2)

**What to do**:
- Modify `bin/config.ps1:198-208` rules for "suggest" and "depends"
- Remove the forced "scoop-cn/" prefix from dependencies
- Allow dependencies to resolve naturally or use bucket-qualified names only when necessary

**Analysis**: The current rules:
```powershell
# Line 199-201: Forces "scoop-cn/" prefix on suggest
'"main/|"extras/|...' → '"scoop-cn/'

# Line 204-207: Forces "scoop-cn/" on depends  
'"depends":\s*"(scoop\-cn/)?' → '"depends": "scoop-cn/'
```

**Decision needed**: Should dependencies be:
1. **Bucket-qualified** (always "scoop-cn/ffmpeg") - Requires fixed bucket name
2. **Unqualified** (just "ffmpeg") - Lets Scoop resolve from all buckets
3. **Configurable** - Based on user preference

**Recommended approach**: Option 2 - Remove these rules entirely. Let dependencies be unqualified (just package name). This allows Scoop to resolve from any bucket the user has added.

**Must NOT do**:
- Keep forcing "scoop-cn/" prefix
- Assume users will always use "scoop-cn" as bucket name

**Recommended Agent Profile**:
- **Category**: `deep` - Architectural change
- **Skills**: None required

**Parallelization**:
- **Can Run In Parallel**: YES (with Task 5)
- **Parallel Group**: Wave 2
- **Blocks**: Task 18 (migration guide)
- **Blocked By**: None

**References**:
- `bin/config.ps1:198-208` - Current suggest/depends rules
- `bucket/bbdown.json:6` - Example of dependency (generated)

**Acceptance Criteria**:

**QA Scenarios**:

```
Scenario: Dependencies without forced prefix
Tool: Bash (PowerShell)
Preconditions: Sample manifest with depends field
Steps:
  1. Run aggregation with updated rules
  2. Check generated manifest depends field
  3. Verify dependency is unqualified (just "ffmpeg", not "scoop-cn/ffmpeg")
Expected Result: Dependencies resolved without bucket prefix
Evidence: .sisyphus/evidence/task-6-depends.log
```

**Commit**: YES (group with Task 5)
- Message: `fix(config): remove forced scoop-cn prefix from dependencies`
- Files: `bin/config.ps1`

---

#### Task 7: Fix Overly Broad Cygwin Regex (Defect #6)

**What to do**:
- Fix `bin/config.ps1:97-99` Cygwin mirror rule
- Current: `'//.*/cygwin/'` - matches ANY domain with cygwin in path
- Fix: Make regex more specific to match only intended URLs
- Target should likely be `cygwin.com` or specific known hosts

**Must NOT do**:
- Keep overly broad regex that could match unintended URLs

**Recommended Agent Profile**:
- **Category**: `quick` - Regex refinement
- **Skills**: None required

**Parallelization**:
- **Can Run In Parallel**: YES
- **Parallel Group**: Wave 2
- **Blocks**: None
- **Blocked By**: None

**References**:
- `bin/config.ps1:96-100` - Current Cygwin rule

**Acceptance Criteria**:

**QA Scenarios**:

```
Scenario: Cygwin regex matches only intended URLs
Tool: Bash (PowerShell)
Preconditions: Sample URLs to test
Steps:
  1. Test regex against cygwin.com URLs (should match)
  2. Test against other domains with 'cygwin' in path (should NOT match)
  3. Test against unrelated URLs (should NOT match)
Expected Result: Only specific Cygwin URLs matched
Evidence: .sisyphus/evidence/task-7-cygwin-regex.log
```

**Commit**: YES
- Message: `fix(config): narrow cygwin regex to prevent false matches`
- Files: `bin/config.ps1`

---

#### Task 8: Fix Incomplete URL Replacement (Defect #7)

**What to do**:
- Add rule for 7-Zip's arm64 pre_install URL
- `bucket/7zip.json:26` has `"Invoke-WebRequest https://www.7-zip.org/a/7zr.exe`
- This URL is not being replaced by existing rules
- Add specific rule or update existing 7-Zip rule

**Must NOT do**:
- Leave URLs unreplaced that should be mirrored

**Recommended Agent Profile**:
- **Category**: `quick` - Add new rule
- **Skills**: None required

**Parallelization**:
- **Can Run In Parallel**: YES
- **Parallel Group**: Wave 2
- **Blocks**: None
- **Blocked By**: None

**References**:
- `bin/config.ps1:84-88` - Existing 7-Zip rule
- `bucket/7zip.json:24-29` - arm64 pre_install with unreplaced URL

**Acceptance Criteria**:

**QA Scenarios**:

```
Scenario: 7zr.exe URL is replaced
Tool: Bash (PowerShell)
Preconditions: 7zip manifest
Steps:
  1. Run replacement on 7zip.json
  2. Check pre_install section
  3. Verify www.7-zip.org URL is replaced with mirror
Expected Result: 7zr.exe URL uses mirror/proxy
Evidence: .sisyphus/evidence/task-8-7zip-url.log
```

**Commit**: YES
- Message: `fix(config): add 7zr.exe URL replacement rule`
- Files: `bin/config.ps1`

---

#### Task 9: Setup Test Infrastructure

**What to do**:
- Create `tests/` directory structure
- Setup Pester (PowerShell testing framework)
- Create initial test runner script
- Add test dependencies to project (if any)

**Must NOT do**:
- Skip testing infrastructure
- Use complex frameworks when simple is sufficient

**Recommended Agent Profile**:
- **Category**: `quick` - Infrastructure setup
- **Skills**: None required

**Parallelization**:
- **Can Run In Parallel**: YES
- **Parallel Group**: Wave 2
- **Blocks**: Tasks 12, 14, 17
- **Blocked By**: None

**References**:
- Pester documentation: https://pester.dev/
- Example PowerShell test structure

**Acceptance Criteria**:

**QA Scenarios**:

```
Scenario: Test infrastructure works
Tool: Bash (PowerShell)
Preconditions: Fresh checkout
Steps:
  1. Install Pester if needed
  2. Run test runner
  3. Verify tests execute (even if none yet)
Expected Result: Test framework operational
Evidence: .sisyphus/evidence/task-9-test-infra.log
```

**Commit**: YES
- Message: `chore(tests): setup Pester test infrastructure`
- Files: `tests/`, `tests/Run-Tests.ps1`

---

### Wave 3: CI/CD Workflow Improvements

#### Task 10: Remove Force Push (Defect #3)

**What to do**:
- Change `bin/auto-update.ps1` (or workflow) to use regular push instead of force
- Line 38: `git push -f origin master` → `git push origin master`
- Handle merge conflicts appropriately (pull first or fail)

**Must NOT do**:
- Keep force push that can overwrite history
- Automatically resolve conflicts without care

**Recommended Agent Profile**:
- **Category**: `quick` - Simple change
- **Skills**: None required

**Parallelization**:
- **Can Run In Parallel**: YES
- **Parallel Group**: Wave 3
- **Blocks**: Task F4
- **Blocked By**: None

**References**:
- `.github/workflows/auto-update.yml:38` - Force push line

**Acceptance Criteria**:

**QA Scenarios**:

```
Scenario: Regular push works
Tool: Bash (Git)
Preconditions: Local changes to push
Steps:
  1. Make test change
  2. Commit
  3. Push without -f flag
  4. Verify push succeeds
Expected Result: Push succeeds without force
Evidence: .sisyphus/evidence/task-10-regular-push.log
```

**Commit**: YES
- Message: `fix(ci): remove force push from auto-update workflow`
- Files: `.github/workflows/auto-update.yml`

---

#### Task 11: Add Concurrency Control (Defect #10)

**What to do**:
- Add `concurrency` section to `.github/workflows/auto-update.yml`
- Prevent overlapping workflow runs
- Cancel in-progress runs or queue them

**Must NOT do**:
- Allow multiple update workflows to run simultaneously
- Cancel workflows without proper cleanup

**Recommended Agent Profile**:
- **Category**: `quick` - Configuration change
- **Skills**: None required

**Parallelization**:
- **Can Run In Parallel**: YES
- **Parallel Group**: Wave 3
- **Blocks**: Task F4
- **Blocked By**: None

**References**:
- GitHub Actions concurrency docs: https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#concurrency

**Acceptance Criteria**:

**QA Scenarios**:

```
Scenario: Concurrency prevents overlap
Tool: Bash (act or manual)
Preconditions: Workflow with concurrency config
Steps:
  1. Trigger workflow
  2. While running, trigger again
  3. Verify second run waits or cancels first
Expected Result: No concurrent executions
Evidence: .sisyphus/evidence/task-11-concurrency.log
```

**Commit**: YES (group with Task 10)
- Message: `feat(ci): add concurrency control to prevent overlapping runs`
- Files: `.github/workflows/auto-update.yml`

---

#### Task 12: Add Testing Stage (Defect #11)

**What to do**:
- Add test execution step to workflow before commit/push
- Run Pester tests
- Validate generated manifests are valid JSON
- Only commit if tests pass

**Must NOT do**:
- Commit untested changes
- Skip validation before pushing

**Recommended Agent Profile**:
- **Category**: `unspecified-high` - Workflow integration
- **Skills**: None required

**Parallelization**:
- **Can Run In Parallel**: YES
- **Parallel Group**: Wave 3
- **Blocks**: Task F4
- **Blocked By**: Task 9 (test infrastructure)

**References**:
- `.github/workflows/auto-update.yml` - Current workflow
- Task 9 output - Test infrastructure

**Acceptance Criteria**:

**QA Scenarios**:

```
Scenario: Tests run before commit
Tool: Bash (act)
Preconditions: Workflow with testing stage
Steps:
  1. Run workflow
  2. Verify tests execute
  3. Verify commit only happens on test pass
  4. Simulate test failure
  5. Verify no commit/push on failure
Expected Result: Tests gate the commit
Evidence: .sisyphus/evidence/task-12-testing-stage.log
```

**Commit**: YES (group with Task 10)
- Message: `feat(ci): add testing stage before commit`
- Files: `.github/workflows/auto-update.yml`, test files

---

#### Task 13: Enable SSH Verification (Defect #12)

**What to do**:
- Remove `GIT_SSH_NO_VERIFY_HOST: "true"` from `.github/workflows/codeberg.yml:23`
- Configure proper SSH host verification
- Add known hosts or use SSH key with verification

**Must NOT do**:
- Keep SSH verification disabled (security risk)

**Recommended Agent Profile**:
- **Category**: `quick` - Security fix
- **Skills**: None required

**Parallelization**:
- **Can Run In Parallel**: YES
- **Parallel Group**: Wave 3
- **Blocks**: Task F4
- **Blocked By**: None

**References**:
- `.github/workflows/codeberg.yml:23` - Disabled verification
- GitHub Actions SSH docs

**Acceptance Criteria**:

**QA Scenarios**:

```
Scenario: SSH verification enabled
Tool: Bash (YAML validation)
Preconditions: Updated workflow file
Steps:
  1. Check workflow file
  2. Verify GIT_SSH_NO_VERIFY_HOST is removed
  3. Verify proper SSH config exists
Expected Result: SSH verification enabled
Evidence: .sisyphus/evidence/task-13-ssh-verify.log
```

**Commit**: YES
- Message: `fix(ci): enable SSH host verification in codeberg mirror`
- Files: `.github/workflows/codeberg.yml`

---

#### Task 14: Add Workflow Validation Tests

**What to do**:
- Create tests for workflow YAML validity
- Validate workflow syntax
- Test workflow logic where possible

**Must NOT do**:
- Skip workflow testing

**Recommended Agent Profile**:
- **Category**: `quick` - Test creation
- **Skills**: None required

**Parallelization**:
- **Can Run In Parallel**: YES
- **Parallel Group**: Wave 3
- **Blocks**: Task F4
- **Blocked By**: Task 9

**References**:
- `.github/workflows/*.yml` - Workflow files to test

**Acceptance Criteria**:

**QA Scenarios**:

```
Scenario: Workflow YAML is valid
Tool: Bash (yamllint or actionlint)
Preconditions: Test suite
Steps:
  1. Run workflow validation tests
  2. Verify no YAML syntax errors
  3. Verify workflow structure is valid
Expected Result: All workflows valid
Evidence: .sisyphus/evidence/task-14-workflow-tests.log
```

**Commit**: YES (group with Task 9)
- Message: `test(ci): add workflow validation tests`
- Files: `tests/workflows/`

---

### Wave 4: Documentation

#### Task 15: Update Outdated References (Defect #13)

**What to do**:
- Update `README.md:11` - "Especially thanks to `https://github.com/duzyn/scoop-cn`"
- Update `README.md:107` - git remote command referencing duzyn/scoop-cn
- Clarify relationship to original project
- Update any other outdated references

**Must NOT do**:
- Leave misleading references to unmaintained project
- Claim credit inappropriately

**Recommended Agent Profile**:
- **Category**: `writing` - Documentation update
- **Skills**: None required

**Parallelization**:
- **Can Run In Parallel**: YES
- **Parallel Group**: Wave 4
- **Blocks**: Task F3
- **Blocked By**: None

**References**:
- `README.md:11` - Acknowledgment line
- `README.md:107` - git remote command

**Acceptance Criteria**:

**QA Scenarios**:

```
Scenario: References are accurate
Tool: Bash (grep)
Preconditions: Updated README
Steps:
  1. Check README for duzyn references
  2. Verify they accurately describe relationship
  3. Verify links are correct
Expected Result: Accurate, up-to-date references
Evidence: .sisyphus/evidence/task-15-references.log
```

**Commit**: YES
- Message: `docs(readme): update outdated references to original project`
- Files: `README.md`

---

#### Task 16: Add Configuration Documentation (Defect #14)

**What to do**:
- Document `bin/config.ps1` structure
- Explain rule syntax and regex patterns
- Document how to add custom mirrors
- Add contribution guidelines for new rules

**Must NOT do**:
- Leave configuration undocumented

**Recommended Agent Profile**:
- **Category**: `writing` - Documentation creation
- **Skills**: None required

**Parallelization**:
- **Can Run In Parallel**: YES
- **Parallel Group**: Wave 4
- **Blocks**: Task F3
- **Blocked By**: None

**References**:
- `bin/config.ps1` - Configuration to document
- Scoop bucket documentation patterns

**Acceptance Criteria**:

**QA Scenarios**:

```
Scenario: Documentation is complete
Tool: Bash (manual review)
Preconditions: Created docs
Steps:
  1. Review configuration docs
  2. Verify all config options documented
  3. Verify examples provided
  4. Verify contribution guide exists
Expected Result: Complete configuration documentation
Evidence: .sisyphus/evidence/task-16-config-docs.log
```

**Commit**: YES
- Message: `docs: add configuration and contribution documentation`
- Files: `docs/configuration.md`, `CONTRIBUTING.md`

---

#### Task 17: Create Comprehensive Test Suite

**What to do**:
- Create tests for all major functionality:
  - Aggregation logic
  - URL replacement rules
  - JSON validation
  - Error handling
- Mock external dependencies (git, network)
- Add integration tests

**Must NOT do**:
- Skip testing critical paths
- Write tests that depend on external state

**Recommended Agent Profile**:
- **Category**: `unspecified-high` - Comprehensive test suite
- **Skills**: None required

**Parallelization**:
- **Can Run In Parallel**: YES
- **Parallel Group**: Wave 4
- **Blocks**: Task F4
- **Blocked By**: Task 9

**References**:
- `bin/lib.ps1` - Functions to test
- `bin/config.ps1` - Rules to test
- Pester documentation

**Acceptance Criteria**:

**QA Scenarios**:

```
Scenario: All tests pass
Tool: Bash (PowerShell)
Preconditions: Test suite
Steps:
  1. Run full test suite
  2. Verify all tests pass
  3. Verify coverage of critical paths
Expected Result: Comprehensive test coverage
Evidence: .sisyphus/evidence/task-17-test-suite.log
```

**Commit**: YES
- Message: `test: add comprehensive test suite`
- Files: `tests/`

---

#### Task 18: Create Migration Guide

**What to do**:
- Document changes from defects #1, #2 (bucket name handling)
- Explain what users need to do if they were using custom bucket names
- Provide migration steps

**Must NOT do**:
- Break existing users without guidance

**Recommended Agent Profile**:
- **Category**: `writing` - Migration documentation
- **Skills**: None required

**Parallelization**:
- **Can Run In Parallel**: YES
- **Parallel Group**: Wave 4
- **Blocks**: Task F3
- **Blocked By**: Tasks 5, 6 (need to know what changed)

**References**:
- Tasks 5, 6 output - What changed

**Acceptance Criteria**:

**QA Scenarios**:

```
Scenario: Migration guide is complete
Tool: Bash (manual review)
Preconditions: Created migration guide
Steps:
  1. Review migration guide
  2. Verify breaking changes documented
  3. Verify migration steps clear
  4. Verify examples provided
Expected Result: Complete migration documentation
Evidence: .sisyphus/evidence/task-18-migration-guide.log
```

**Commit**: YES
- Message: `docs: add migration guide for v2.0 changes`
- Files: `docs/migration.md`

---

### Wave FINAL: Verification

#### Task F1: Full Integration Test

**What to do**:
- Run complete aggregation process end-to-end
- Verify all fixes work together
- Test with all 10 upstream buckets
- Verify output manifests are valid

**Recommended Agent Profile**:
- **Category**: `deep` - Full integration test
- **Skills**: None required

**Parallelization**:
- **Can Run In Parallel**: YES (with F2, F3, F4)
- **Parallel Group**: Wave FINAL
- **Blocks**: None
- **Blocked By**: Tasks 1-4, 5-8 (script fixes)

**Acceptance Criteria**:

**QA Scenarios**:

```
Scenario: Full aggregation works
Tool: Bash (PowerShell)
Preconditions: All fixes applied
Steps:
  1. Run complete aggregation
  2. Verify all repos cloned
  3. Verify replacements applied
  4. Verify manifests are valid JSON
  5. Verify no hardcoded bucket names
Expected Result: Complete successful aggregation
Evidence: .sisyphus/evidence/f1-integration.log
```

**Commit**: NO (test only)

---

#### Task F2: Code Quality Review

**What to do**:
- Review all changes for code quality
- Check for PowerShell best practices
- Verify error handling is complete
- Check for security issues

**Recommended Agent Profile**:
- **Category**: `unspecified-high` - Code review
- **Skills**: None required

**Parallelization**:
- **Can Run In Parallel**: YES
- **Parallel Group**: Wave FINAL
- **Blocks**: None
- **Blocked By**: Tasks 1-18

**Acceptance Criteria**:

**QA Scenarios**:

```
Scenario: Code quality passes
Tool: Bash (PSScriptAnalyzer)
Preconditions: All changes complete
Steps:
  1. Run PSScriptAnalyzer
  2. Check for warnings/errors
  3. Review manually for issues
Expected Result: No quality issues
Evidence: .sisyphus/evidence/f2-quality.log
```

**Commit**: NO (review only)

---

#### Task F3: Documentation Review

**What to do**:
- Review all documentation changes
- Verify accuracy
- Check completeness
- Validate links and examples

**Recommended Agent Profile**:
- **Category**: `writing` - Documentation review
- **Skills**: None required

**Parallelization**:
- **Can Run In Parallel**: YES
- **Parallel Group**: Wave FINAL
- **Blocks**: None
- **Blocked By**: Tasks 15, 16, 18

**Acceptance Criteria**:

**QA Scenarios**:

```
Scenario: Documentation is high quality
Tool: Bash (markdownlint)
Preconditions: All docs complete
Steps:
  1. Run markdown linting
  2. Verify spelling/grammar
  3. Check all links work
Expected Result: Documentation quality passes
Evidence: .sisyphus/evidence/f3-docs.log
```

**Commit**: NO (review only)

---

#### Task F4: End-to-End Workflow Test

**What to do**:
- Test CI/CD workflows in isolation
- Verify workflow syntax is valid
- Test workflow logic
- Ensure changes don't break existing functionality

**Recommended Agent Profile**:
- **Category**: `unspecified-high` - Workflow testing
- **Skills**: None required

**Parallelization**:
- **Can Run In Parallel**: YES
- **Parallel Group**: Wave FINAL
- **Blocks**: None
- **Blocked By**: Tasks 10-14

**Acceptance Criteria**:

**QA Scenarios**:

```
Scenario: Workflows are valid
Tool: Bash (actionlint)
Preconditions: All workflow changes complete
Steps:
  1. Run actionlint on workflows
  2. Validate YAML syntax
  3. Check workflow logic
Expected Result: Workflows pass validation
Evidence: .sisyphus/evidence/f4-workflows.log
```

**Commit**: NO (test only)

---

## Commit Strategy

| After Task | Message | Files | Verification |
|------------|---------|-------|--------------|
| 1-4 | `fix(lib): atomic updates, error handling, JSON validation, BOM fix` | `bin/lib.ps1` | PowerShell tests |
| 5-6 | `fix(config): remove hardcoded bucket names from rules` | `bin/config.ps1` | Config tests |
| 7 | `fix(config): narrow cygwin regex` | `bin/config.ps1` | Regex tests |
| 8 | `fix(config): add 7zr.exe URL replacement` | `bin/config.ps1` | Replacement tests |
| 9, 14, 17 | `test: setup Pester and add test suite` | `tests/` | Test execution |
| 10-12 | `fix(ci): remove force push, add concurrency and testing` | `.github/workflows/auto-update.yml` | Workflow validation |
| 13 | `fix(ci): enable SSH verification` | `.github/workflows/codeberg.yml` | Security check |
| 15 | `docs(readme): update outdated references` | `README.md` | Link check |
| 16, 18 | `docs: add configuration and migration documentation` | `docs/` | Doc review |

---

## Success Criteria

### Verification Commands

```powershell
# PowerShell tests
Invoke-Pester tests/

# JSON validation
Get-ChildItem bucket/*.json | ForEach-Object { 
    Get-Content $_.FullName | ConvertFrom-Json | Out-Null 
}

# Workflow validation
actionlint .github/workflows/*.yml

# Check for hardcoded bucket names
grep -r "scoop-cn" bucket/ --include="*.json" | grep -v "description\|homepage\|license"
```

### Final Checklist

- [ ] All 14 defects addressed
- [ ] No hardcoded bucket names in generated manifests
- [ ] Atomic updates implemented with rollback
- [ ] Git operations have error handling
- [ ] JSON validation occurs after replacement
- [ ] No force push in CI/CD
- [ ] Concurrency control enabled
- [ ] Testing stage in workflow
- [ ] SSH verification enabled
- [ ] Documentation updated
- [ ] All tests pass
- [ ] Migration guide provided

---

## Risk Assessment

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Breaking existing users with bucket name changes | High | High | Provide migration guide, clear documentation |
| Atomic update implementation bugs | Medium | High | Extensive testing, rollback validation |
| CI/CD workflow syntax errors | Low | Medium | Validate workflows before commit |
| Missing test coverage | Medium | Medium | Comprehensive test suite, code review |
| Documentation gaps | Low | Low | Documentation review task |

---

## Post-Implementation Notes

After all tasks complete:
1. Verify all 6183 manifests are valid
2. Run a full aggregation test
3. Verify CI/CD pipeline works end-to-end
4. Monitor first few automated runs for issues
5. Gather user feedback on bucket name changes
