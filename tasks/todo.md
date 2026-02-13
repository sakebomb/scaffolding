# Task Plan — README Split + CHANGELOG (#36, #43)

> Updated: 2026-02-13
> Branch: `docs/readme-changelog`
> Status: Complete
> Issue: #36, #43

## Objective

Slim README from 593 → ~180 lines by splitting detailed docs into `docs/`. Create CHANGELOG.md for v1.0.0.

## Plan

### Phase 1: Create docs/
- [x] 1. `docs/configuration.md` — all flags, .scaffoldrc, completions, --verify, --install-template, --migrate, --add, --keep, --update, --dry-run, --version
- [x] 2. `docs/templates.md` — template authoring guide, community templates, required files, supported languages table, archetypes
- [x] 3. `docs/architecture.md` — CLAUDE.md constitution, slash commands, agents, testing tiers, task management, permissions, Ralph, Makefile, GitHub project mgmt, CI/CD, pre-commit, Docker, rollback

### Phase 2: Slim README
- [x] 4. Rewrite README.md: why, quick start, feature overview (one-liners), supported languages, contributing (slim), links to docs/, license. Target: <200 lines
- [x] 5. Fix stale test counts (32 suites/721 assertions → 33/732)

### Phase 3: CHANGELOG
- [x] 6. Create CHANGELOG.md covering all v1.0.0 features (PRs #1–#45)

### Phase 4: Ship
- [ ] 7. Commit, push, PR. Closes #36 + #43

## Results

- README: 593 → 122 lines
- docs/configuration.md: 131 lines (all CLI flags and config)
- docs/templates.md: 89 lines (languages, archetypes, template authoring)
- docs/architecture.md: 236 lines (full "what's inside" reference)
- CHANGELOG.md: 82 lines (all v1.0.0 features)
- All content preserved, no broken links
