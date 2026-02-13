# Task Plan — Scaffolding Framework v1

> Updated: 2026-02-13
> Branch: `feat/initial-structure`
> Status: ✅ Complete

---

## Objective

Build a GitHub template repository + bash CLI init script that scaffolds a project optimized for working with Claude Code — language-agnostic core with pluggable language-specific configurations, interactive project planning, custom slash commands, expanded agent roster, guided permissions, and optional Ralph Wiggum autonomous loop integration.

## Decisions (Locked)

| Decision | Choice | Rationale |
|----------|--------|-----------|
| License | MIT | Maximum permissiveness, universal recognition |
| Init script language | Bash | Zero dependencies, works everywhere |
| Self-destruct after init | Yes (default), `--keep` to preserve | Clean project; scaffold artifacts don't confuse Claude |
| `.claude/settings.json` | Tiered: safe auto-approved, project-specific prompted, destructive always gated | See permissions table below |
| Project planning | Load existing plan, build interactively, or skip | Claude gets project context from session 1 |
| Language architecture | Subfolders with `CONVENTIONS.md` per language | Modular, cleanable, not front-loaded |
| Ralph Wiggum | Optional during init | Adds autonomous loop for power users |

### Permission Tiers

**Auto-approved (safe defaults — always on):**
- File read/write/edit within project directory
- Glob and grep searches
- `git status`, `git diff`, `git log`, `git branch`, `git add`, `git stash`
- `make test`, `make test-unit`, `make lint`, `make check`
- `ls`, `pwd`, `which`

**Prompted during init (user chooses yes/no):**
- `git commit` — auto-allow or require approval each time?
- `git push` — auto-allow or require approval each time?
- Package managers (`pip install`, `npm install`, `cargo build`, `go get`)
- Docker commands (`docker build`, `docker compose`)

**Never auto-approved (always require confirmation):**
- `rm -rf`, `git push --force`, `git reset --hard`
- Anything outside project directory
- Secrets/credential access

## Architecture

```
scaffolding/                           # The template repo
├── README.md                          # Motivation, usage, contributing
├── CLAUDE.md                          # Agent constitution (language-agnostic)
├── LICENSE                            # MIT
├── scaffold                           # Bash CLI init script
├── Makefile                           # Language-aware (Python/TS/Go/Rust)
├── .gitignore
│
├── .claude/                           # Claude Code configuration
│   ├── settings.json                  # Tiered permission defaults
│   ├── commands/                      # Custom slash commands
│   │   ├── plan.md                    # /plan — structured planning
│   │   ├── review.md                  # /review — diff review
│   │   ├── test.md                    # /test — run & analyze tests
│   │   ├── lesson.md                  # /lesson — add to lessons learned
│   │   ├── checkpoint.md              # /checkpoint — commit working state
│   │   ├── status.md                  # /status — show progress
│   │   └── simplify.md               # /simplify — reduce complexity
│   └── hooks/                         # Optional hook scripts
│
├── tasks/                             # Task management
│   ├── todo.md                        # Plan template
│   ├── lessons.md                     # Lessons learned
│   └── tests.md                       # Test registry
│
├── agents/                            # Agent specifications
│   ├── README.md                      # Convention docs
│   ├── plan-agent.md                  # Plan Agent spec
│   ├── research-agent.md              # Research Agent spec
│   ├── code-review-agent.md           # Code Review Agent spec
│   ├── test-runner-agent.md           # Test Runner Agent spec
│   ├── build-validator-agent.md       # Build Validator — compile, type-check, lint
│   ├── code-architect-agent.md        # Code Architect — system design decisions
│   ├── code-simplifier-agent.md       # Code Simplifier — reduce complexity
│   └── verify-agent.md               # Verify — full pre-merge validation
│
├── scratch/                           # Ephemeral subagent workspace
│   ├── .gitkeep
│   └── README.md
│
├── tests/                             # Test directory structure
│   ├── unit/
│   ├── integration/
│   └── agent/
│
├── templates/                         # Language-specific (removed after init)
│   ├── python/
│   │   ├── CONVENTIONS.md             # Python best practices for Claude
│   │   ├── gitignore.append
│   │   ├── pyproject.toml.tmpl
│   │   ├── ruff.toml
│   │   └── conftest.py
│   ├── typescript/
│   │   ├── CONVENTIONS.md             # TS best practices for Claude
│   │   ├── gitignore.append
│   │   ├── package.json.tmpl
│   │   ├── tsconfig.json
│   │   └── eslint.config.mjs
│   ├── go/
│   │   ├── CONVENTIONS.md             # Go best practices for Claude
│   │   ├── gitignore.append
│   │   └── go.mod.tmpl
│   └── rust/
│       ├── CONVENTIONS.md             # Rust best practices for Claude
│       ├── gitignore.append
│       └── Cargo.toml.tmpl
│
└── templates/ralph/                   # Optional Ralph Wiggum integration
    ├── ralph-loop.sh                  # Autonomous loop script
    ├── PROMPT_build.md                # Build mode prompt
    └── PROMPT_plan.md                 # Plan mode prompt
```

**After `./scaffold` runs** (e.g., Python + Ralph):
```
my-project/
├── README.md
├── CLAUDE.md                          # Base + Python CONVENTIONS.md appended
├── LICENSE
├── .gitignore                         # Base + Python entries merged
├── Makefile                           # Configured for Python
├── .claude/
│   ├── settings.json                  # Permissions from user choices
│   └── commands/                      # Slash commands ready to use
│       ├── plan.md
│       ├── review.md
│       ├── test.md
│       ├── lesson.md
│       ├── checkpoint.md
│       ├── status.md
│       └── simplify.md
├── tasks/
│   ├── todo.md                        # User's project plan
│   ├── lessons.md
│   └── tests.md
├── agents/
│   ├── README.md
│   └── *.md                           # All agent specs
├── scratch/
│   └── .gitkeep
├── tests/
│   ├── unit/
│   ├── integration/
│   └── agent/
├── pyproject.toml
├── ruff.toml
├── conftest.py
├── scripts/                           # (if Ralph enabled)
│   └── ralph-loop.sh
├── PROMPT_build.md                    # (if Ralph enabled)
└── PROMPT_plan.md                     # (if Ralph enabled)
```

## Plan

### Phase 1: Foundation ✅
- [x] 1. Initialize git repo
- [x] 2. Create proper `.gitignore`
- [x] 3. Reorganize files into `tasks/` directory
- [x] 4. Create `scratch/` with `.gitkeep` + README
- [x] 5. Create `agents/` with README
- [x] 6. Create `tests/unit/`, `tests/integration/`, `tests/agent/`
- [x] 7. Write project `README.md`
- [x] 8. Add MIT `LICENSE`

### Phase 2: Claude Code Configuration ✅
- [x] 9. Create `.claude/settings.json` with tiered permissions (allow/deny/hooks)
- [x] 10. Create `.claude/skills/` — 7 slash commands (modern SKILL.md format with frontmatter):
    - `/plan`, `/review`, `/test`, `/lesson`, `/checkpoint`, `/status`, `/simplify`
- [x] 11. Create `.claude/hooks/protect-main-branch.sh` — blocks commit/push on main/master
- [x] 12. Add parallelization rules to `CLAUDE.md` (Section 4.8)
- [x] 13. Add `{{PROJECT_NAME}}` / `{{PROJECT_DESCRIPTION}}` placeholders + skills reference table to `CLAUDE.md`

### Phase 3: Agents ✅
- [x] 14. Extract existing agents to individual specs in `agents/`:
    - `plan-agent.md`, `research-agent.md`, `code-review-agent.md`, `test-runner-agent.md`
- [x] 15. Write new agent specs:
    - `build-validator-agent.md` — compile, type-check, lint, verify build succeeds
    - `code-architect-agent.md` — system design, architecture decisions, tradeoff analysis
    - `code-simplifier-agent.md` — reduce complexity, suggest refactors, flag over-engineering
    - `verify-agent.md` — full pre-merge validation (build + test + lint + diff review)
- [x] 16. Update `agents/README.md` with full roster, decision tree, orchestration rules, and contribution guide

### Phase 4: Language Templates ✅
- [x] 17. `templates/python/` — CONVENTIONS.md, pyproject.toml.tmpl, ruff.toml, conftest.py, gitignore.append
- [x] 18. `templates/typescript/` — CONVENTIONS.md, package.json.tmpl, tsconfig.json, eslint.config.mjs, gitignore.append
- [x] 19. `templates/go/` — CONVENTIONS.md, go.mod.tmpl, gitignore.append
- [x] 20. `templates/rust/` — CONVENTIONS.md, Cargo.toml.tmpl, gitignore.append
- [x] 21. Makefile rewritten — supports all 4 languages, added `fmt`, `typecheck`, `build` targets, Rust-specific test handling

### Phase 5: Ralph Wiggum Integration (Optional) ✅
- [x] 22. Create `templates/ralph/ralph-loop.sh` — iterative loop with completion detection, logging, cooldown
- [x] 23. Create `PROMPT_build.md` (single-task build cycle) and `PROMPT_plan.md` (plan analysis/creation)
- [x] 24. Maps tasks/todo.md as shared state, CLAUDE.md as constitution, <done>COMPLETE</done> as signal

### Phase 6: CLI Init Script ✅
- [x] 25. Core `scaffold` script — full interactive flow:
    - Project name + description
    - Language selection with per-language recommendations
    - Permission preferences (guided alternative to `--dangerously-skip-permissions`)
    - Git remote URL (optional)
    - Ralph Wiggum integration (optional)
- [x] 26. Project planning integration — three paths:
    - Build interactively (guided questions → structured plan)
    - Load from file
    - Skip (blank template)
- [x] 27. Template engine — replaces placeholders, appends CONVENTIONS.md, copies configs, creates src dirs
- [x] 28. Cleanup — removes `scaffold`, `templates/`, leaves clean project
- [x] 29. Git init + initial commit with descriptive message
- [x] 30. `--help`, `--keep`, `--non-interactive` flags all working
- [x] Verified end-to-end: non-interactive test produces clean 35-file project with correct structure

### Phase 7: Testing & Documentation ✅
- [x] 31. `shellcheck` validation of scaffold script — manual review, fixed 4 issue categories:
    - Replaced all `eval` with `printf -v` (injection safety)
    - Added `sed_escape` helper for user input in sed substitutions
    - Fixed placeholder replacement ordering (conventions append before sed)
    - Separated `local` declarations for `set -u` compatibility
- [x] 32. Behavior tests — 7 test suites, 252 assertions, all pass:
    - Python, TypeScript, Go, Rust, None (language-agnostic)
    - `--keep` flag preservation
    - Permissions configuration
- [x] 33. Update `tasks/tests.md` — coverage summary, commands, gap tracking
- [x] 34. Comprehensive README — motivation, full init walkthrough, before/after, contributing, language matrix

### Checkpoints

- [x] **CP1** (after Phase 1): Repo structured, README done. ✅
- [x] **CP2** (after Phase 3): All agents specced, slash commands created. ✅
- [x] **CP3** (after Phase 4): All language templates + Makefile. ✅
- [x] **CP4** (after Phase 6): Full init flow works end-to-end. Demo run verified. ✅
- [x] **CP5** (after Phase 7): Tests pass (252/252), README complete. ✅

## Results

All 34 steps complete across 7 phases. Key deliverables:

- **scaffold** — bash CLI init script (~450 lines), tested end-to-end for all 4 languages + none
- **CLAUDE.md** — agent constitution with 7 sections, parallelization rules, skills reference, template placeholders
- **.claude/** — settings.json (tiered permissions), 7 skills, 1 hook (main branch protection)
- **agents/** — 8 agent specs with context budgets and orchestration rules
- **templates/** — 4 languages (Python, TypeScript, Go, Rust) + Ralph Wiggum
- **Makefile** — 4-language support with auto-detection, 6 targets
- **tests/** — behavior test suite: 7 suites, 252 assertions
- **README.md** — comprehensive docs with motivation, walkthrough, before/after, contributing guide
