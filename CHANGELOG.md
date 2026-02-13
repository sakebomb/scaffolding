# Changelog

All notable changes to Scaffold will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [1.0.0] - 2026-02-13

### Added

**Core scaffold flow**
- Interactive init: project name, description, language, archetype, permissions, plan, git remote
- Non-interactive mode (`--non-interactive`) with sensible defaults
- Dry-run mode (`--dry-run`) to preview output without writing files
- Graceful rollback on mid-run failure — cleans up partial artifacts
- `--keep` flag to preserve scaffold script and templates after init

**Language support**
- Python — pytest, ruff, mypy, pyproject.toml
- TypeScript — vitest, eslint, tsc, package.json, tsconfig.json
- Go — go test, golangci-lint, go.mod
- Rust — cargo test, clippy, rustfmt, Cargo.toml
- Language-agnostic mode (none)

**Project archetypes**
- CLI — entry point with argument parsing and subcommand structure
- API — HTTP server with routes and health check endpoint
- Library — public module with exported functions

**Claude Code integration**
- Agent constitution (`CLAUDE.md`) with guardrails, planning, testing tiers, recovery
- Pre-configured permissions (`.claude/settings.json`) with tiered model
- 14 slash commands: `/start`, `/plan`, `/review`, `/test`, `/refactor`, `/lesson`, `/checkpoint`, `/status`, `/simplify`, `/index`, `/save`, `/load`, `/backlog`, `/doctor`
- 8 agent specifications: Plan, Research, Code Review, Test Runner, Build Validator, Code Architect, Code Simplifier, Verify
- Task management (`tasks/todo.md`, `tasks/lessons.md`, `tasks/tests.md`, `tasks/session.md`)
- Main branch protection hook (`.claude/hooks/protect-main-branch.sh`)

**Multi-language and migration**
- `--add` to layer a second language into an existing project
- `--add` interactive mode with dynamic language selection
- `--add --dir` for monorepo subdirectory layouts
- `--migrate` to add Claude Code config to existing projects (auto-detects language, idempotent)

**Template system**
- Community template support via `--install-template` (git repos or local dirs)
- `--list-templates` to show built-in + installed templates
- Template validation (requires `CONVENTIONS.md` + `gitignore.append`)

**Configuration and CLI**
- `.scaffoldrc` persistent defaults (`--save-defaults`)
- Shell completions for bash and zsh (`--completions`)
- `--version` flag
- `--verify` post-scaffold health check
- `--update` to pull latest skills, hooks, and agents
- Installable CLI via `install.sh` (curl-installable)

**Generated project files**
- GitHub Actions CI workflow (language-specific setup)
- GitHub Actions release workflow (tag-triggered, changelog-based)
- Pre-commit config with language-specific linting + secret scanning
- Issue templates (bug, feature, task) and PR template
- Label taxonomy (type, priority, status) via `make setup-github`
- `.env.example`, `CHANGELOG.md`, `SECURITY.md`, `GETTING_STARTED.md`
- Language-aware Makefile (test, lint, fmt, typecheck, build, check)
- Optional Docker support (multi-stage Dockerfile + docker-compose.yml)
- Optional VS Code settings and extensions per language
- Optional Ralph Wiggum autonomous loop integration

**Testing**
- 33 test suites with 732 assertions covering all features
- Smoke tests for Python (ruff) and Go (gofmt/golangci-lint)

### Internal

- Refactored `apply_templates()` from 742-line monolith into 3 focused functions + orchestrator
- Extracted `replace_placeholders()` helper for duplicate sed patterns
- Zero shellcheck warnings across all bash files

[1.0.0]: https://github.com/sakebomb/scaffold/releases/tag/v1.0.0
