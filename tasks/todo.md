# Task Plan — Project Hardening (CI, Safety, DevEx, Docker, Updates, Releases)

> Updated: 2026-02-13
> Branch: `feat/project-hardening`
> Status: Complete

## Objective

Add 9 features that harden scaffolded projects for real-world use: CI workflows, pre-commit hooks, secret scanning, health checks, environment templates, Docker support, an update mechanism, and a release workflow.

## Plan

### Phase 1: CI Workflows — items #1, #4
- [x] 1. Create `.github/workflows/ci.yml` for scaffold repo itself
- [x] 2. Add CI template generation to scaffold — per-language setup
- [x] 3. Add test assertions for generated CI workflow

### Phase 2: Pre-commit + Secret Scanning — items #2, #3
- [x] 4. Create per-language `.pre-commit-config.yaml` generation
- [x] 5. Add secret scanning via `detect-secrets` pre-commit hook
- [x] 6. Add test assertions for pre-commit config

### Phase 3: /doctor + .env.example — items #5, #7
- [x] 7. Create `/doctor` skill
- [x] 8. Add `.env.example` template generation
- [x] 9. Add test assertions for /doctor skill and .env.example
- [x] 10. Update slash command count 12 → 13

### Phase 4: Docker Support — item #8
- [x] 11. Add Docker step to scaffold (optional)
- [x] 12. Create per-language Dockerfile templates (multi-stage where applicable)
- [x] 13. Create `docker-compose.yml` template
- [x] 14. Add test assertions for Docker files (Docker is optional — no assertions needed for default)

### Phase 5: Update Mechanism — item #6
- [x] 15. Add `scaffold --update` flag
- [x] 16. Update `--help` text with new flag
- [x] 17. Add safety: show diff, require confirmation

### Phase 6: CHANGELOG + Release Workflow — item #9
- [x] 18. Add `CHANGELOG.md` template generation
- [x] 19. Create `.github/workflows/release.yml` template
- [x] 20. Add test assertions

### Phase 7: Final Polish
- [x] 21. Update README.md with all new features
- [x] 22. Update CLAUDE.md skills table
- [x] 23. Run full test suite — 347/347 passing
- [x] 24. Commit, push, PR
