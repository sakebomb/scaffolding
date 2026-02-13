---
name: doctor
description: Check project health — environment, dependencies, tools, and configuration
argument-hint: ""
user-invocable: true
allowed-tools: "Read, Bash(python *), Bash(node *), Bash(npm *), Bash(go *), Bash(cargo *), Bash(make *), Bash(git *), Bash(gh *), Bash(which *), Bash(pip *), Bash(pre-commit *)"
---

Run a health check on the project environment. Report what's working and what needs attention.

## Instructions

Run each check below and report results using this format:

```
## Project Health Check

| Check | Status | Details |
|-------|--------|---------|
| Git repo | ✅ | On branch main, 12 commits |
| Language env | ⚠️ | Python 3.12 found, but no .venv active |
| Dependencies | ❌ | Not installed — run `pip install -e '.[dev]'` |
| ...  | ... | ... |
```

### Checks to Run

#### 1. Git
- Is this a git repo? (`git rev-parse --is-inside-work-tree`)
- Current branch and commit count
- Any uncommitted changes? (`git status --porcelain`)
- Is a remote configured? (`git remote -v`)

#### 2. Language Environment
Detect language from config files (pyproject.toml, package.json, go.mod, Cargo.toml):

- **Python**: Is Python installed? What version? Is a virtual environment active? (`$VIRTUAL_ENV`)
- **TypeScript**: Is Node.js installed? What version? Is `node_modules/` present?
- **Go**: Is Go installed? What version?
- **Rust**: Is Rust installed? What version? (`rustc --version`)

#### 3. Dependencies
- Are project dependencies installed?
  - Python: `pip list` shows project package
  - TypeScript: `node_modules/` exists and `package-lock.json` matches
  - Go: `go.sum` exists
  - Rust: `Cargo.lock` exists

#### 4. Development Tools
- Linter available? (ruff, eslint, golangci-lint, clippy)
- Formatter available? (ruff, eslint, gofmt, rustfmt)
- Type checker available? (mypy, tsc, built-in)
- `make` available?
- `pre-commit` installed? Hooks active? (`pre-commit --version`, `.git/hooks/pre-commit`)

#### 5. Claude Code
- `.claude/settings.json` exists?
- `.claude/skills/` directory has skills?
- `CLAUDE.md` exists?
- `tasks/todo.md` exists?

#### 6. GitHub Integration
- `gh` CLI installed? (`which gh`)
- `gh` authenticated? (`gh auth status`)
- Issue labels created? (check with `gh label list` if authenticated)

#### 7. Tests
- Does `make test-unit` work? (run it, report pass/fail)
- If it fails, show the error summary (not full output)

### After the Check

1. Summarize: "X of Y checks passed"
2. For any failures, show the exact command to fix it
3. If everything passes: "Project is healthy — ready to build."

## Rules

- Run checks quickly — skip anything that would take >10 seconds
- Don't install anything automatically — just report what's missing and how to fix it
- If `make test-unit` has no tests yet, report as ⚠️ (warning), not ❌ (failure)
- Group related issues together (e.g., "venv not active" and "deps not installed" are the same root cause)
