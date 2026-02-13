---
name: refactor
description: Guided refactoring with before/after validation
argument-hint: "<file path, module, or pattern>"
user-invocable: true
allowed-tools: "Read, Grep, Glob, Edit, Bash(make test*), Bash(git diff*), Bash(git stash*)"
context: fork
agent: general-purpose
---

Perform a guided refactoring of the specified code with validation at each step.

## Scope

- If `$ARGUMENTS` is a file: refactor that specific file.
- If `$ARGUMENTS` is a module/directory: analyze and refactor across the module.
- If `$ARGUMENTS` is empty: analyze recently changed files (`git diff --name-only main...HEAD`).

## Workflow

### 1. Analyze
- Read the target code and identify refactoring opportunities.
- Categorize: extract function, rename, simplify conditional, reduce duplication, improve types, restructure module.
- Estimate risk level for each change (low/medium/high).

### 2. Baseline
- Run `make test` (or appropriate test command) to establish a passing baseline.
- If tests fail before refactoring, stop and report — don't refactor broken code.
- Record the baseline state: `git stash` or note current diff.

### 3. Plan
Present the refactoring plan to the user:

```
## Refactoring Plan: <target>

| # | Change | Risk | Files |
|---|--------|------|-------|
| 1 | Description | low | file.py:20-35 |
| 2 | Description | medium | file.py:50-80 |

Estimated complexity reduction: X → Y (metric)
```

Wait for approval before proceeding.

### 4. Apply
- Apply changes **one at a time**, smallest and safest first.
- After each change: run tests immediately.
- If tests fail: revert that change, report the failure, and continue with remaining changes.
- Never apply the next change until the current one passes tests.

### 5. Report
Write results to `scratch/refactor_latest.md`:

```
## Refactoring Report: <target>

### Applied
- [x] Change 1 — description (tests pass)
- [x] Change 2 — description (tests pass)

### Skipped
- [ ] Change 3 — reason (tests failed / user declined)

### Before/After
- Lines: X → Y
- Complexity: before → after
- Tests: all passing
```

Return a ≤5 line summary to the main context.

## Rules

- **Never break tests.** If a change causes failures, revert it immediately.
- **One change at a time.** Don't batch multiple refactors into one edit.
- **Preserve behavior.** Refactoring changes structure, not functionality.
- **No scope creep.** Don't add features, fix bugs, or change behavior during refactoring.
- **Ask before high-risk changes.** Anything touching public APIs, shared interfaces, or core logic needs explicit approval.
