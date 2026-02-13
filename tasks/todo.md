# Task Plan — v1.1.0

> Updated: 2026-02-13
> Status: Pending Approval
> Issues: #38, #39, #44, #47, #48, #49

## Objective

Ship v1.1.0 with CLI lifecycle features, cross-platform compat, and polish.

## Plan

6 issues, 4 phases. Each phase is one branch → one PR.

---

### Phase 1: Bash 4 compat + CI matrix (#44)
> Branch: `fix/bash-compat`

The script uses 3 bash 4+ features. macOS ships bash 3.2. Fix for portability:

- [x] 1. Replace `${var,,}` with `to_lower()` using `tr '[:upper:]' '[:lower:]'`
- [x] 2. Replace `declare -A _RC_SET=()` with delimited string `_RC_KEYS`
- [x] 3. Replace `mapfile -t` with `while IFS= read -r` loop
- [x] 4. Add CI matrix: ubuntu-latest + macos-latest
- [x] 5. Add `sed_inplace()` for macOS BSD sed compat (19 calls in scaffold, 4 in tests)
- [x] 6. Guard `COMP_ARRAY[@]` for bash 3.2 empty array + `set -u` compat
- [x] 7. Use `ENVIRON` for awk multiline var (BSD awk compat)
- [x] 8. Add `run_scaffold_cmd()` test helper to surface CI errors
- [x] 9. Full test suite: 732/732 pass locally + CI green on ubuntu + macOS
- [x] 10. PR #50 — ready to merge

---

### Phase 2: Small features (#38, #48, #49)
> Branch: `feat/v1.1-polish`

Three small, independent additions:

**Fish completions (#38)**
- [ ] 7. Add `print_fish_completions()` using Fish `complete -c scaffold` syntax
- [ ] 8. Add `fish` case to `--completions` handler in `parse_flags()` + auto-detect from `$SHELL`
- [ ] 9. Add completions to `show_help()`, update bash/zsh completion flag lists
- [ ] 10. Test: `--completions fish` output contains `complete -c scaffold`

**`.scaffoldrc` validation (#48)**
- [ ] 11. Add `validate_scaffoldrc()` — check each key against known set, warn on unknowns
- [ ] 12. Simple typo suggestion: check if unknown key is 1-2 chars off from a known key
- [ ] 13. Validate values where possible (e.g., `LANGUAGE` must be python|typescript|go|rust|none)
- [ ] 14. Test: unknown key warns, valid config is silent

**`--migrate` multi-language (#49)**
- [ ] 15. Modify `detect_language()` to return all matches (not just first)
- [ ] 16. When multiple detected + interactive: prompt user to pick primary
- [ ] 17. When multiple detected + non-interactive: pick first, print info message
- [ ] 18. Test: multi-language project prompts for selection

- [ ] 19. Run full test suite, commit, push, PR

---

### Phase 3: `--eject` + `--self-update` + `--uninstall` (#39, #47)
> Branch: `feat/lifecycle`

**`--eject` (#39)**
- [ ] 20. Add `--eject` flag to `parse_flags()`
- [ ] 21. Implement `run_eject()`: remove scaffold, templates/, install.sh, .scaffold-version
- [ ] 22. Prompt before removing optional files (tasks/todo.md, tasks/lessons.md)
- [ ] 23. `--eject --force` skips confirmation
- [ ] 24. Test: artifacts removed, project files preserved

**`--self-update` (#47)**
- [ ] 25. Add `--self-update` to `parse_flags()`
- [ ] 26. Implement: curl latest scaffold script from GitHub, compare versions, replace if newer
- [ ] 27. Show version diff (old → new), no-op if already latest
- [ ] 28. Test: self-update replaces script (mock with local file)

**`--uninstall` (#47)**
- [ ] 29. Add `--uninstall` to `parse_flags()`
- [ ] 30. Implement: remove ~/.local/bin/scaffold, ~/.scaffold/, prompt for ~/.scaffoldrc
- [ ] 31. `--uninstall --force` skips confirmation
- [ ] 32. Test: files removed

- [ ] 33. Run full test suite, commit, push, PR

---

### Phase 4: Release
- [ ] 34. Bump SCAFFOLD_VERSION to "1.1.0"
- [ ] 35. Update CHANGELOG.md with v1.1.0 section
- [ ] 36. Update docs/ with new flags
- [ ] 37. Commit, push, PR
- [ ] 38. Merge, tag v1.1.0, create GitHub Release
- [ ] 39. Close issues #38, #39, #44, #47, #48, #49
