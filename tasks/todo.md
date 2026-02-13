# Task Plan — P2 Features: IDE Settings, README Badges, SECURITY.md, /refactor

> Updated: 2026-02-13
> Branch: `feat/p2-features`
> Status: Complete
> Issues: #11, #12, #13, #14

## Objective

Implement four P2-medium features: VS Code IDE settings, README badges, SECURITY.md template, and /refactor skill.

## Plan

### Phase 1: SECURITY.md (#13) + README Badges (#12)
- [x] 1. Add SECURITY.md template generation to `apply_templates()`
- [x] 2. Add badges (CI, license, language) to generated project README
- [x] 3. Add test assertions for SECURITY.md and badges

### Phase 2: IDE Settings (#11)
- [x] 4. Add `ENABLE_VSCODE=false` global + `step_vscode()` prompt
- [x] 5. Generate `.vscode/settings.json` per language (formatter, ruler, tab size)
- [x] 6. Generate `.vscode/extensions.json` per language (recommended extensions)
- [x] 7. Wire into `main()`, update dry-run report
- [x] 8. Add test assertions

### Phase 3: /refactor Skill (#14)
- [x] 9. Create `.claude/skills/refactor/SKILL.md`
- [x] 10. Update command count 13 → 14 everywhere
- [x] 11. Add test assertion for refactor skill

### Phase 4: Polish
- [x] 12. Update README (new sections, counts, trees)
- [x] 13. Run full test suite
- [x] 14. Commit, push, PR
