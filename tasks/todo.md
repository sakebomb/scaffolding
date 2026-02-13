# Task Plan — P3 Features: Shell Completion, Graceful Rollback, Multi-Language --add

> Updated: 2026-02-13
> Branch: `feat/p3-features`
> Status: Complete
> Issues: #15, #16, #17

## Objective

Implement three P3-low features: shell completion for scaffold flags, graceful rollback on failure, and multi-language `--add` flag.

## Plan

### Phase 1: Shell Completion (#15)
- [x] 1. Add `--completions` flag to `parse_flags()` that outputs a bash completion script
- [x] 2. Completion script covers all flags: `--help`, `--keep`, `--non-interactive`, `--dry-run`, `--update`, `--completions`
- [x] 3. Add test assertions for `--completions` output
- [x] 4. Document in README how to enable (`source <(./scaffold --completions)`)

### Phase 2: Graceful Rollback (#16)
- [x] 5. Track files created during the run (array of paths)
- [x] 6. Add `trap` handler on ERR that lists partial files and offers rollback
- [x] 7. Never delete files that existed before scaffold ran (snapshot pre-existing files)
- [x] 8. Add test assertions for rollback behavior

### Phase 3: Multi-Language `--add` (#17)
- [x] 9. Add `--add <language>` flag to `parse_flags()`
- [x] 10. In add mode: skip project basics/permissions/git init, only layer language config
- [x] 11. Append language conventions to CLAUDE.md (without duplicating existing sections)
- [x] 12. Append to .gitignore (not overwrite)
- [x] 13. Update Makefile with prefixed targets (e.g., `test-ts`, `lint-ts`)
- [x] 14. Update CI workflow to include both languages
- [x] 15. Add test assertions for at least one `--add` scenario

### Phase 4: Polish
- [x] 16. Update README (new flags, counts)
- [x] 17. Run full test suite
- [x] 18. Commit, push, PR
