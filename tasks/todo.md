# Task Plan — P3 Features: Interactive --add, --verify, Plugin Registry

> Updated: 2026-02-13
> Branch: `feat/p3-round1`
> Status: Complete — ready for PR
> Issues: #28, #29, #30

## Objective

Implement three P3-low features: interactive language selection for `--add`, post-scaffold verification, and community template installation.

## Plan

### Phase 1: Interactive `--add` (#29)
- [x] 1. Modify `parse_flags()` — `--add` without an argument sets `ADD_MODE=true` but leaves `ADD_LANGUAGE=""`
- [x] 2. In `main()`, when `ADD_MODE=true` and `ADD_LANGUAGE=""`, call `prompt_choice` with available languages
- [x] 3. Non-interactive fallback: default to first language (python)
- [x] 4. Add test: `--add` without arg in non-interactive mode scaffolds python
- [x] 5. Add test: `--add python` still works unchanged

### Phase 2: `--verify` flag (#30)
- [x] 6. Add `--verify` flag to `parse_flags()`, add `VERIFY_MODE=false` global
- [x] 7. Create `run_verify()` — runs checks, prints pass/fail per check, returns exit code
- [x] 8. Checks: git repo, required files, .scaffold-version, valid JSON, no placeholders
- [x] 9. Add test: `--verify` on a freshly scaffolded project → exit 0, all checks pass
- [x] 10. Add test: `--verify` detects leftover placeholder → exit 1, reports failure

### Phase 3: Plugin/template registry (#28)
- [x] 11. Add `--install-template <url-or-path>` flag to `parse_flags()`
- [x] 12. Create `install_template()` — copy/clone to `~/.scaffold/templates/<name>/`
- [x] 13. Template validation: must contain `CONVENTIONS.md` and `gitignore.append`
- [x] 14. Add `--list-templates` flag — lists built-in + installed templates
- [x] 15. Create `list_available_languages()` helper — scans built-in + installed template dirs
- [x] 16. Wire `list_available_languages()` into `--add` validation (accepts installed templates)
- [x] 17. Add test: `--install-template` from local path installs and `--list-templates` shows it
- [x] 18. Add test: invalid template (missing CONVENTIONS.md) fails validation

### Phase 4: Polish
- [x] 19. Update README (new flags, template authoring docs)
- [x] 20. Update tasks/tests.md
- [x] 21. Run full test suite — 721/721 across 32 suites
- [ ] 22. Commit, push, PR
