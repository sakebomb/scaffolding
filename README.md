# Scaffold

A CLI for bootstrapping repositories optimized for [Claude Code](https://docs.anthropic.com/en/docs/claude-code).

Run `scaffold`, answer a few questions, and get a fully configured project with an agent constitution, slash commands, tiered test structure, task management, and language-specific tooling — ready for Claude Code from session one.

## Why

Starting a new project with Claude Code usually means spending your first few sessions teaching it how you want to work. Scaffold gives Claude Code the right context from the start:

- **Agent constitution** (`CLAUDE.md`) with guardrails, planning workflow, testing tiers, and recovery patterns
- **Pre-configured permissions** (`.claude/settings.json`) — safe ops auto-approved, destructive ops always gated
- **14 slash commands** — `/start`, `/plan`, `/review`, `/test`, `/checkpoint`, `/status`, and more
- **8 agent specifications** — Plan, Research, Code Review, Test Runner, Build Validator, and more
- **Lessons-learned system** (`tasks/lessons.md`) that compounds across sessions
- **Language-specific conventions** for Python, TypeScript, Go, and Rust

## Quick Start

### Install (Recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/sakebomb/scaffold/main/install.sh | bash
```

Then:

```bash
mkdir my-project && cd my-project
scaffold
claude
```

### Or Clone

```bash
git clone https://github.com/sakebomb/scaffold.git my-project
cd my-project
./scaffold
claude
```

Once inside Claude Code, type `/start` for a guided walkthrough.

## What It Does

```
═══ Project Setup ═══
? Project name: my-api
? Description: REST API for widget management

═══ Language ═══
  1) python    2) typescript    3) go    4) rust    5) none

═══ Archetype ═══
  1) none    2) cli    3) api    4) library

═══ Permissions ═══
? Auto-approve git commit? [Y/n]
? Auto-approve git push? [y/N]
```

After the flow, scaffold applies your choices, cleans up its own files, initializes git, and creates the first commit.

## Features

| Feature | Description |
|---------|-------------|
| **4 languages** | Python, TypeScript, Go, Rust — each with linter, formatter, type checker, test runner |
| **3 archetypes** | CLI, API, Library — language-aware starter files with no framework dependencies |
| **14 slash commands** | `/start`, `/plan`, `/review`, `/test`, `/refactor`, `/checkpoint`, `/status`, and more |
| **8 agents** | Plan, Research, Code Review, Test Runner, Build Validator, Code Architect, Simplifier, Verify |
| **CI/CD** | GitHub Actions for lint+test on PR, GitHub Release on version tag |
| **`--add`** | Layer a second language into an existing project, with monorepo `--dir` support |
| **`--migrate`** | Add Claude Code config to an existing project (auto-detects language) |
| **`--verify`** | Post-scaffold health check (required files, valid JSON, no leftover placeholders) |
| **`--dry-run`** | Preview what scaffold would create without writing anything |
| **`.scaffoldrc`** | Persistent defaults for repeat scaffolding |
| **Shell completions** | Bash and Zsh tab-completion for all flags |
| **Community templates** | Install custom language templates via `--install-template` |
| **Docker** | Optional multi-stage Dockerfile + docker-compose.yml |
| **Pre-commit hooks** | Linting + secret scanning via `.pre-commit-config.yaml` |
| **Ralph Wiggum** | Optional autonomous AI coding loop integration |

## Supported Languages

| Language | Linter | Formatter | Type Checker | Test Runner |
|----------|--------|-----------|-------------|-------------|
| Python | ruff | ruff | mypy | pytest |
| TypeScript | eslint | eslint | tsc | vitest |
| Go | golangci-lint | gofmt | (built-in) | go test |
| Rust | clippy | rustfmt | (built-in) | cargo test |

## Documentation

| Doc | What It Covers |
|-----|---------------|
| **[Configuration](docs/configuration.md)** | All CLI flags, `.scaffoldrc`, shell completions, `--verify`, `--install-template` |
| **[Templates](docs/templates.md)** | Supported languages, archetypes, community template authoring guide |
| **[Architecture](docs/architecture.md)** | What's inside: CLAUDE.md, slash commands, agents, testing, permissions, CI/CD, project structure |

## Contributing

1. Fork the repo
2. Create a feature branch: `git checkout -b feat/your-feature`
3. Make changes and run tests: `bash tests/test_scaffold.sh`
4. Commit with conventional commits: `feat: add new feature`
5. Open a PR

**What to contribute**: new language templates, new agents, new slash commands, bug fixes, documentation.

### Running Tests

```bash
bash tests/test_scaffold.sh              # All tests (33 suites, 732 assertions)
bash tests/test_scaffold.sh python       # Single language
bash tests/test_scaffold.sh keep         # Single feature
```

## License

[MIT](LICENSE)
