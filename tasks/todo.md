# Task Plan — Full Codebase Review and Cleanup (#37)

> Updated: 2026-02-13
> Branch: `refactor/v1-review`
> Status: In Progress
> Issue: #37

## Objective

Clean up the scaffold codebase before v1.0.0 release. No functional changes — cleanup only.

## Plan

### Phase 1: shellcheck fixes
- [x] 1. Fix SC2146: `find` grouping with `\( \)` in update function (line 276)
- [x] 2. Fix SC2034: remove unused `ci_lang_name` variable (line 2009)
- [x] 3. Fix SC2129: consolidate consecutive redirects to same file (4 occurrences)
- [x] 4. Fix SC2034 in test: prefix unused `install_output` with `_`

### Phase 2: Dead code removal
- [x] 5. Wire `list_available_languages()` into interactive `--add` prompt (it's defined but not called — the prompt currently hardcodes `python typescript go rust`)

### Phase 3: Refactor `apply_templates()` (752 lines → ~5 focused functions)
- [x] 6. Extract `apply_language_config()` — handles .tmpl processing, config copying, gitignore append
- [x] 7. Extract `apply_common_files()` — README, GETTING_STARTED, CI, .env, CHANGELOG, SECURITY, pre-commit, release workflow
- [x] 8. Extract `apply_optional_features()` — Docker, VS Code, Ralph
- [x] 9. Slim `apply_templates()` to an orchestrator calling the above

### Phase 4: Extract helpers for duplicate code
- [x] 10. Extract `replace_placeholders()` helper — wraps the repeated `sed` pattern for {{PROJECT_NAME}}/{{PROJECT_DESCRIPTION}}

### Phase 5: Minor fixes
- [x] 11. Fix `show_help()` duplicate numbering (5, 5 → 5, 6)

### Phase 6: Verify
- [x] 12. Run shellcheck — zero warnings
- [x] 13. Run full test suite — 732/732
- [ ] 14. Commit, push, PR

## Results

- shellcheck: 0 warnings on scaffold + test_scaffold.sh
- Tests: 732/732 (33 suites, 0 failures)
- `apply_templates()` reduced from 742 lines to 12-line orchestrator
- 3 new focused functions: `apply_language_config()`, `apply_common_files()`, `apply_optional_features()`
- `replace_placeholders()` helper eliminates duplicate `sed_escape` + `sed -i` pattern
- `show_help()` numbering fixed (5,5,6,7 → 5,6,7,8)
