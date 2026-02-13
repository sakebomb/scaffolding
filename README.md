# Scaffold

A project template and CLI for bootstrapping repositories optimized for [Claude Code](https://docs.anthropic.com/en/docs/claude-code).

Clone it, run `./scaffold`, and get a fully configured project with an agent constitution, slash commands, tiered test structure, task management, and language-specific tooling — ready for Claude Code from session one.

## Why This Exists

Starting a new project with Claude Code usually means spending your first few sessions teaching it how you want to work — your commit conventions, testing expectations, when to plan vs. just build, what's safe to auto-approve. That setup is repetitive and easy to get wrong.

Scaffold solves this by giving Claude Code the right context from the very first session:

- **An agent constitution** (`CLAUDE.md`) that defines guardrails, planning workflow, testing tiers, subagent delegation, and recovery patterns — so Claude operates with senior-engineer standards instead of guessing.
- **Pre-configured permissions** (`.claude/settings.json`) with a tiered model — safe operations auto-approved, destructive operations always gated, and middle-ground operations that you decide during init.
- **13 slash commands** (`/start`, `/plan`, `/review`, `/test`, `/lesson`, `/checkpoint`, `/status`, `/simplify`, `/index`, `/save`, `/load`, `/backlog`, `/doctor`) so common workflows are one command away.
- **8 agent specifications** for subagent delegation — Plan, Research, Code Review, Test Runner, Build Validator, Code Architect, Code Simplifier, and Verify — each with defined context budgets and output contracts.
- **A lessons-learned system** (`tasks/lessons.md`) that accumulates across sessions, so mistakes compound into preventive rules instead of being forgotten.
- **Language-specific conventions** for Python, TypeScript, Go, and Rust that get appended to `CLAUDE.md` during init — best practices, linter configs, project structure, and testing patterns.

The goal: zero warm-up time. Your first Claude Code session starts productive.

## Quick Start

### Option A: GitHub Template (Recommended)

1. Click **"Use this template"** at the top of this repo
2. Name your new repository and create it
3. Clone your new repo and run the init script:

```bash
git clone https://github.com/you/my-project.git
cd my-project
./scaffold
claude
```

### Option B: Git Clone

```bash
git clone https://github.com/sakebomb/scaffold.git my-project
cd my-project
./scaffold
claude
```

The scaffold script detects the cloned scaffold history and reinitializes git automatically.

Once inside Claude Code, type `/start` for a guided walkthrough, or see `GETTING_STARTED.md` for the full onboarding guide.

## What the Init Flow Looks Like

Running `./scaffold` walks you through an interactive setup:

```
╔═══════════════════════════════════════════════════╗
║          Scaffold — Claude Code Setup            ║
╚═══════════════════════════════════════════════════╝

═══ Project Setup ═══
? Project name [my-project]: my-api
? Short description [A project built with Claude Code]: REST API for widget management

═══ Language Selection ═══
? Select primary language:
  1) python    — pytest, ruff, mypy
  2) typescript — vitest, eslint, tsc
  3) go        — go test, golangci-lint
  4) rust      — cargo test, clippy
  5) none      — language-agnostic (configure later)

═══ Claude Code Permissions ═══
? Auto-approve git commit? [Y/n]: y
? Auto-approve git push? [y/N]: n
? Auto-approve package manager commands? [y/N]: y
? Auto-approve docker commands? [y/N]: n

═══ Ralph Wiggum (Autonomous Loop) ═══
? Enable Ralph Wiggum autonomous loop? [y/N]: n

═══ Project Plan ═══
? How would you like to set up your project plan?
  1) Build one now   — answer a few questions to generate a plan
  2) Load from file  — import an existing plan (markdown)
  3) Skip            — use the blank template

═══ Git Remote (Optional) ═══
? Git remote URL (leave blank to skip):

═══ GitHub Project Management ═══
Issue templates and PR template are included in .github/
? Create issue labels (type, priority, status)? [Y/n]: y
? Create a GitHub Projects kanban board? [y/N]: n
```

After completing the flow, scaffold applies your choices, cleans up its own files, initializes git, and creates the first commit.

### Non-Interactive Mode

For automation or CI:

```bash
./scaffold --non-interactive
```

Defaults: directory name as project name, python language, safe permissions only, no Ralph Wiggum, blank plan template.

### Keeping Scaffold Artifacts

By default, the `scaffold` script and `templates/` directory are removed after init. To preserve them:

```bash
./scaffold --keep
```

## Before / After

**Before** (what you clone):

```
scaffold/
├── scaffold                    # Init script (removed after init)
├── templates/                  # Language configs (removed after init)
│   ├── python/                 #   CONVENTIONS.md, pyproject.toml.tmpl, ruff.toml, ...
│   ├── typescript/             #   CONVENTIONS.md, package.json.tmpl, tsconfig.json, ...
│   ├── go/                     #   CONVENTIONS.md, go.mod.tmpl, ...
│   ├── rust/                   #   CONVENTIONS.md, Cargo.toml.tmpl, ...
│   └── ralph/                  #   ralph-loop.sh, PROMPT_build.md, PROMPT_plan.md
├── CLAUDE.md                   # Agent constitution (with placeholders)
├── .claude/
│   ├── settings.json           # Permission defaults
│   ├── skills/                 # 13 slash commands
│   └── hooks/                  # Main branch protection
├── .github/
│   ├── ISSUE_TEMPLATE/         # Bug, feature, task templates
│   └── pull_request_template.md
├── agents/                     # 8 agent specs
├── tasks/                      # Plan, lessons, test registry, session state
├── tests/                      # Tier directories
├── scratch/                    # Subagent workspace
├── Makefile                    # Language-aware dev tasks
└── ...
```

**After** `./scaffold` (e.g., Python + Ralph Wiggum):

```
my-api/
├── CLAUDE.md                   # Customized with project name + Python conventions
├── GETTING_STARTED.md          # First-session onboarding guide
├── .claude/
│   ├── settings.json           # Permissions from your choices
│   ├── skills/                 # /start, /plan, /review, /test, /lesson, /checkpoint,
│   │                           #   /status, /simplify, /index, /save, /load, /backlog, /doctor
│   └── hooks/                  # protect-main-branch.sh
├── .github/
│   ├── ISSUE_TEMPLATE/         # Bug, feature, task issue forms
│   ├── workflows/
│   │   ├── ci.yml              # Lint + typecheck + test on PR
│   │   └── release.yml         # GitHub Release on version tag
│   └── pull_request_template.md
├── agents/                     # plan, research, code-review, test-runner, build-validator,
│   └── *.md                    #   code-architect, code-simplifier, verify
├── tasks/
│   ├── todo.md                 # Your project plan
│   ├── lessons.md              # Knowledge base — mistakes, patterns, troubleshooting, insights
│   ├── tests.md                # Test registry template
│   └── session.md              # Session state for /save and /load
├── tests/
│   ├── unit/
│   ├── integration/
│   └── agent/
├── scratch/
├── Makefile                    # Configured for Python
├── pyproject.toml              # Project config with your name/description
├── ruff.toml                   # Linter config
├── conftest.py                 # Pytest fixtures
├── src/my_api/
│   └── __init__.py
├── scripts/                    # (Ralph Wiggum)
│   └── ralph-loop.sh
├── PROMPT_build.md             # (Ralph Wiggum)
├── PROMPT_plan.md              # (Ralph Wiggum)
├── .pre-commit-config.yaml     # Linting + secret scanning hooks
├── .env.example                # Environment variable template
├── CHANGELOG.md                # Keep a Changelog format
├── .gitignore                  # Base + Python entries
└── LICENSE                     # MIT
```

No `scaffold` script. No `templates/` directory. Clean project, ready to go.

## What's Inside

### CLAUDE.md — The Agent Constitution

The core of the framework. Defines how Claude Code should behave in your project:

- **Core principles** — simplicity first, no band-aids, minimal impact
- **Guardrails** — never commit to main, never hardcode secrets, confirm before destructive actions
- **Planning workflow** — structured plans in `tasks/todo.md` with checkpoints and approval gates
- **Subagent strategy** — 8 agents with context budgets and orchestration rules
- **Testing tiers** — unit, integration, agent behavior — fail-fast ordering
- **Recovery** — lessons learned system that compounds across sessions

Language-specific conventions (Python, TypeScript, Go, Rust) are appended during init — covering linting, testing, project structure, and idiomatic patterns.

### First Session Onboarding

New to Claude Code? After running `./scaffold`:

1. Run `claude` to start Claude Code
2. Type `/start` — a guided walkthrough that helps you create your first plan and (optionally) your first GitHub issue
3. Or just tell Claude what to build: *"I want to build [your idea]. Help me create a plan."*

A `GETTING_STARTED.md` file is also generated in your project with a full walkthrough, example prompts, and a command reference.

### Slash Commands

| Command | What It Does |
|---------|-------------|
| `/start` | Guided first-session onboarding — plan your project and create your first issue |
| `/plan` | Create a structured plan with confidence assessment in `tasks/todo.md` |
| `/review` | Review changes with Four Questions evidence validation |
| `/test` | Run tests by tier, analyze failures, propose fixes |
| `/lesson` | Record a lesson — mistakes, positive patterns, troubleshooting, insights |
| `/checkpoint` | Stage, commit, and update `tasks/todo.md` progress |
| `/status` | Show project progress — plan completion + git state |
| `/simplify` | Analyze code complexity and suggest simplifications |
| `/index` | Generate `PROJECT_INDEX.md` for fast session orientation |
| `/save` | Snapshot session state to `tasks/session.md` |
| `/load` | Restore context from previous session and orient |
| `/backlog` | Manage GitHub issues — view, pick, create, close work items |
| `/doctor` | Check project health — environment, dependencies, tools |

### Agents

| Agent | Purpose | Context Budget |
|-------|---------|---------------|
| Plan | Break down complex tasks into checkpointed plans | 30% |
| Research | Deep-dive investigation, docs, API exploration | 40% |
| Code Review | Pre-commit diff review for bugs, security, style | 20% |
| Test Runner | Run tests, interpret failures, propose fixes | 25% |
| Build Validator | Compile, type-check, lint, verify build | 15% |
| Code Architect | System design decisions, tradeoff analysis | 35% |
| Code Simplifier | Reduce complexity, flag over-engineering | 25% |
| Verify | Full pre-merge validation pipeline | 30% |

### Tiered Testing

Tests run in order of speed. A failure at any tier blocks the next.

| Command | Tier | What It Runs |
|---------|------|-------------|
| `make test-unit` | 1 | Fast, isolated unit tests |
| `make test-integration` | 2 | Cross-component integration tests |
| `make test-agent` | 3 | Agent behavior and anti-hallucination checks |
| `make test` | All | Full suite, fail-fast |
| `make check` | All | Lint + typecheck + full suite (pre-PR gate) |

### Task Management & Session Continuity

The `tasks/` directory is the "always available" context layer — what Claude reads to orient at session start:

| File | What It Tracks |
|------|---------------|
| `tasks/todo.md` | Current plan, progress, decisions |
| `tasks/lessons.md` | Knowledge base — mistakes, positive patterns, troubleshooting, insights |
| `tasks/tests.md` | Test coverage map, gaps, flaky tests |
| `tasks/session.md` | Active focus, open questions, next steps, git state |

Combined with `PROJECT_INDEX.md` (generated by `/index`), these files let Claude resume any session without re-reading the entire codebase. The philosophy: **compress often, persist the essentials, look up details on demand.**

### Permission Tiers

| Tier | Examples | Behavior |
|------|----------|----------|
| Auto-approved | File read/write, git status/diff/log, make targets, searches | Always allowed |
| User-configured | git commit, git push, package managers, docker | You choose during init |
| Never auto-approved | `rm -rf`, `--force`, `--hard`, secrets access | Always requires confirmation |

### Ralph Wiggum (Optional)

[Ralph Wiggum](https://ralph-wiggum.ai/) is an autonomous AI coding loop. When enabled during init, it adds:

- `scripts/ralph-loop.sh` — iterative loop: plan, build, test, commit, repeat
- `PROMPT_build.md` — single-task build cycle prompt
- `PROMPT_plan.md` — plan analysis/creation prompt

Each iteration runs with a fresh context window. Progress persists via `tasks/todo.md`.

```bash
# Autonomous planning
./scripts/ralph-loop.sh plan

# Autonomous building
./scripts/ralph-loop.sh build
```

### Makefile

Language-aware with auto-detection (Cargo.toml, go.mod, tsconfig.json, pyproject.toml):

| Target | Description |
|--------|-------------|
| `make test` | Run all test tiers |
| `make lint` | Run linter |
| `make fmt` | Auto-format code |
| `make typecheck` | Run type checker |
| `make build` | Compile/build |
| `make check` | lint + typecheck + test (pre-PR gate) |
| `make setup-github` | Create issue labels (requires `gh` CLI) |

### GitHub Project Management

Scaffold includes issue templates, a PR template, and label taxonomy to integrate with GitHub's project management features:

- **Issue templates** (`.github/ISSUE_TEMPLATE/`) — form-based templates for bugs, features, and tasks with structured fields (severity, scope, acceptance criteria)
- **PR template** (`.github/pull_request_template.md`) — standardized format with What/Why/How sections, test plan checklist, and issue linking
- **Labels** — type labels (bug, feature, task, chore, refactor), priority labels (P0-critical through P3-low), and status labels (needs-triage, ready, blocked, in-progress). Created via `make setup-github` or during `./scaffold` init
- **`/backlog` command** — bridges GitHub Issues with local task management. View open issues by priority, pick an issue to start working on (creates branch, sets labels, writes plan), create new issues, or close completed ones

During `./scaffold` init, if the GitHub CLI is authenticated, you'll be prompted to create labels and optionally a GitHub Projects kanban board.

### CI/CD

Every scaffolded project gets GitHub Actions workflows out of the box:

- **CI workflow** (`.github/workflows/ci.yml`) — runs `make check` (lint + typecheck + test) on every PR and push to main. Language-specific setup included (Python venv, Node.js, Go, Rust toolchain).
- **Release workflow** (`.github/workflows/release.yml`) — triggered by version tags (`v*`). Extracts notes from `CHANGELOG.md` and creates a GitHub Release.
- **CHANGELOG.md** — follows [Keep a Changelog](https://keepachangelog.com/) format, ready for versioned releases.

### Pre-commit Hooks & Secret Scanning

Scaffolded projects include a `.pre-commit-config.yaml` with:

- **Common hooks** — trailing whitespace, end-of-file fixer, YAML validation, large file detection, merge conflict detection
- **Language-specific linting** — ruff (Python), eslint (TypeScript), golangci-lint (Go), cargo fmt + clippy (Rust)
- **Secret scanning** — `detect-secrets` catches accidentally staged API keys, tokens, and credentials

To activate: `pip install pre-commit && pre-commit install`

### Docker (Optional)

When enabled during `./scaffold` init, adds production-ready Docker support:

- **Dockerfile** — language-specific with multi-stage builds (Go, Rust, TypeScript) or slim images (Python)
- **docker-compose.yml** — app service with commented-out database example

### Updating Existing Projects

If scaffold improves after you've already scaffolded a project, you can pull updates:

```bash
# Requires the scaffold script (use --keep during init, or re-download)
./scaffold --update
```

This compares your `.claude/skills/`, `.claude/hooks/`, and `agents/` against the latest from the scaffold repo, shows a diff, and applies changes with your confirmation.

## Supported Languages

| Language | Linter | Formatter | Type Checker | Test Runner | Config Files |
|----------|--------|-----------|-------------|-------------|-------------|
| Python | ruff | ruff | mypy | pytest | pyproject.toml, ruff.toml, conftest.py |
| TypeScript | eslint | eslint | tsc | vitest | package.json, tsconfig.json, eslint.config.mjs |
| Go | golangci-lint | gofmt | (built-in) | go test | go.mod |
| Rust | clippy | rustfmt | (built-in) | cargo test | Cargo.toml |
| None | — | — | — | — | (configure manually later) |

## Contributing

### How to Contribute

1. Fork the repo
2. Create a feature branch: `git checkout -b feat/your-feature`
3. Make changes
4. Run tests: `bash tests/test_scaffold.sh`
5. Commit with conventional commits: `feat: add new feature`
6. Open a PR

### What to Contribute

- **New language templates** — add a new `templates/<language>/` directory with `CONVENTIONS.md`, config templates, and `gitignore.append`
- **New agents** — add a spec in `agents/` following the existing format (purpose, when to use, inputs, outputs, context budget)
- **New slash commands** — add a `SKILL.md` in `.claude/skills/<command>/` with YAML frontmatter
- **Bug fixes** — especially for edge cases in the scaffold script
- **Documentation** — improvements to README, CLAUDE.md, or agent specs

### Running Tests

```bash
# All tests (7 suites, 347 assertions)
bash tests/test_scaffold.sh

# Single language
bash tests/test_scaffold.sh python
bash tests/test_scaffold.sh typescript
bash tests/test_scaffold.sh go
bash tests/test_scaffold.sh rust
bash tests/test_scaffold.sh none

# Feature tests
bash tests/test_scaffold.sh keep
bash tests/test_scaffold.sh permissions
```

### Project Structure for Contributors

```
scaffold/
├── scaffold                    # Main init script (bash)
├── templates/                  # Language templates + Ralph Wiggum
├── .claude/                    # Claude Code configuration
│   ├── settings.json           # Permission tiers
│   ├── skills/                 # Slash command definitions (13 commands)
│   └── hooks/                  # Git safety hooks
├── .github/                    # Issue templates, PR template, CI/release workflows
├── agents/                     # Agent specifications
├── tasks/                      # Plan, lessons, test registry
├── tests/
│   └── test_scaffold.sh        # Behavior tests (317 assertions)
└── CLAUDE.md                   # Agent constitution (with placeholders)
```

## License

[MIT](LICENSE) — use it however you want.
