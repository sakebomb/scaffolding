# Task Plan — P1 Features: --migrate, Smoke Tests, Installable CLI

> Updated: 2026-02-13
> Branch: `feat/p1-round2`
> Status: Complete
> Issues: #21, #22, #23

## Objective

Implement three P1-high features: --migrate for existing projects, end-to-end smoke tests, and a curl-installable CLI.

## Plan

### Phase 1: `--migrate` for existing projects (#21)
- [x] 1. Add `--migrate` flag to `parse_flags()`
- [x] 2. Add `detect_language()` — infer language from existing config files (pyproject.toml → python, etc.)
- [x] 3. Add `detect_existing_components()` — check which scaffold components already exist
- [x] 4. Add `run_migrate()` — generate only missing components, never overwrite
- [x] 5. Append language conventions to CLAUDE.md if not present
- [x] 6. Skip git init if .git already exists, skip cleanup_artifacts
- [x] 7. Add test: migrate a bare Python project (only pyproject.toml + src/) → verify CLAUDE.md, skills, agents, tasks added
- [x] 8. Add test: migrate idempotent (running twice doesn't duplicate)

### Phase 2: End-to-end smoke tests (#22)
- [x] 9. Add `test_smoke_python()` — scaffold python project, run `make lint` + `make fmt` (skips if ruff not installed)
- [x] 10. Add `test_smoke_go()` — scaffold go project, run `make fmt` + `make lint` (skips lint if golangci-lint not installed)
- [x] 11. Skip smoke tests gracefully if tooling not installed (warn, don't fail)
- [x] 12. Wire into test runner as `bash tests/test_scaffold.sh smoke`

### Phase 3: Installable CLI (#23)
- [x] 13. Add `--version` flag that prints scaffold version (git tag or hardcoded)
- [x] 14. Create `install.sh` — curl one-liner that downloads scaffold + templates to `~/.scaffold/` and symlinks to PATH
- [x] 15. Modify scaffold to locate templates relative to install location (TEMPLATE_DIR resolution)
- [x] 16. Add install/usage docs to README

### Phase 4: Polish
- [x] 17. Update README (new flags, counts, install instructions)
- [x] 18. Run full test suite — 683/683 across 20 suites
- [ ] 19. Commit, push, PR

## Results

- 683 assertions across 20 test suites, all passing
- New features: `--migrate`, `--version`, `install.sh`, smoke tests
- Template resolution: `TEMPLATE_DIR` supports both local repo and `~/.scaffold/` installs
