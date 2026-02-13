# Task Plan — P2 Features: .scaffoldrc, Zsh Completions, Monorepo --dir, Version Tracking

> Updated: 2026-02-13
> Branch: `feat/p2-round2`
> Status: Complete — ready for PR
> Issues: #24, #25, #26, #27

## Objective

Implement four P2-medium features: persistent user defaults, zsh completion, monorepo subdirectory support, and version tracking in scaffolded projects.

## Plan

### Phase 1: `.scaffoldrc` defaults file (#24)
- [x] 1. Add `load_scaffoldrc()` — read `~/.scaffoldrc` (bash key=value) into globals after defaults, before `parse_flags()`
- [x] 2. Only set globals that haven't been overridden by CLI flags (precedence: CLI > .scaffoldrc > hardcoded)
- [x] 3. Add `--save-defaults` flag — write current choices to `~/.scaffoldrc` after scaffold completes
- [x] 4. Add test: scaffoldrc sets LANGUAGE=go → non-interactive scaffold produces Go project
- [x] 5. Add test: CLI flag overrides scaffoldrc

### Phase 2: Zsh completion support (#25)
- [x] 6. Extend `--completions` to accept optional arg: `--completions bash` / `--completions zsh`
- [x] 7. Auto-detect from `$SHELL` if no arg given (default to bash)
- [x] 8. Add `print_zsh_completions()` using `#compdef` / `_arguments` format
- [x] 9. Add test: `--completions zsh` outputs `#compdef`, `_arguments`, all flags
- [x] 10. Add test: `--completions bash` still works unchanged

### Phase 3: Monorepo `--add --dir` (#26)
- [x] 11. Add `--dir <path>` flag to `parse_flags()` (only valid with `--add`)
- [x] 12. Modify `run_add_language()` — when `ADD_DIR` is set, place config files in subdirectory
- [x] 13. Namespace Makefile targets with dir prefix: `test-backend-py` instead of `test-py`
- [x] 14. Scope CI workflow steps to subdirectory: `cd <dir> && make test-<lang>`
- [x] 15. Add test: `--add python --dir backend` puts pyproject.toml in backend/, Makefile targets prefixed

### Phase 4: Version tracking in scaffolded projects (#27)
- [x] 16. Write `.scaffold-version` file during scaffold (contains SCAFFOLD_VERSION + date)
- [x] 17. `--update` reads `.scaffold-version` to show what version the project was scaffolded with
- [x] 18. Add test: `.scaffold-version` exists after scaffold, contains version string

### Phase 5: Polish
- [x] 19. Update README (new flags, .scaffoldrc docs, zsh completion)
- [x] 20. Update tasks/tests.md with new test commands
- [x] 21. Run full test suite — 704/704 across 26 suites
- [ ] 22. Commit, push, PR
