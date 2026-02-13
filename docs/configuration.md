# Configuration

All CLI flags, persistent defaults, and post-scaffold tools.

## CLI Flags

### `--non-interactive`

Skip all prompts and use defaults:

```bash
scaffold --non-interactive
```

Defaults: directory name as project name, python language, no archetype, safe permissions only, no Ralph Wiggum, blank plan template.

### `--dry-run`

Preview what scaffold would create without writing anything:

```bash
scaffold --non-interactive --dry-run
```

### `--keep`

Preserve the `scaffold` script and `templates/` directory after init (required for `--add` and `--update`):

```bash
scaffold --keep
```

By default, these are removed after init to keep the project clean.

### `--version`

```bash
scaffold --version
```

### `--add` — Multi-Language Projects

Layer a second language into an existing scaffolded project:

```bash
scaffold --add typescript     # Specify language
scaffold --add               # Interactive selection
```

This appends language conventions to `CLAUDE.md`, adds config files (without overwriting existing ones), updates `.gitignore`, adds prefixed Makefile targets (`test-ts`, `lint-ts`, `fmt-ts`, `typecheck-ts`), and updates the CI workflow. Requires templates to be present (use `--keep` on initial run).

When called without a language argument, `--add` prompts for interactive selection (or defaults to python in `--non-interactive` mode).

For monorepo layouts, place the language in a subdirectory:

```bash
scaffold --add python --dir backend
```

Config files go in `backend/`, Makefile targets are namespaced (`test-backend-py`, `lint-backend-py`), and commands are scoped to the subdirectory.

### `--migrate` — Existing Projects

Add Claude Code configuration to a project that already has code:

```bash
cd existing-project
scaffold --migrate
```

This auto-detects your language (from `pyproject.toml`, `package.json`, `go.mod`, or `Cargo.toml`), then adds only what's missing — `CLAUDE.md`, skills, hooks, agents, tasks, test structure — without overwriting any existing files. Running twice is safe (idempotent).

### `--verify` — Health Check

Run a post-scaffold health check:

```bash
scaffold --verify
```

Checks: git repo initialized, required files present (`CLAUDE.md`, `.claude/settings.json`, `Makefile`, `.gitignore`), `.scaffold-version` exists, `settings.json` is valid JSON, no leftover `{{placeholders}}`. Exits 0 on pass, 1 on failure.

### `--update` — Pull Latest

Update skills, hooks, and agents from the scaffold repo:

```bash
scaffold --update
```

Compares your `.claude/skills/`, `.claude/hooks/`, and `agents/` against the latest from the scaffold repo, shows a diff, and applies changes with your confirmation. Requires the scaffold script (use `--keep` during init, or re-download).

### `--install-template` — Community Templates

Install a community language template:

```bash
scaffold --install-template https://github.com/user/scaffold-template-ruby
scaffold --install-template ./local-template-dir
```

Templates are installed to `~/.scaffold/templates/<name>/` and become available in `--add` language selection. A valid template must contain at minimum `CONVENTIONS.md` and `gitignore.append`.

### `--list-templates`

List all available templates (built-in + installed):

```bash
scaffold --list-templates
```

## Shell Completions

Enable tab-completion for scaffold flags:

```bash
# Bash
source <(scaffold --completions bash)
scaffold --completions bash >> ~/.bashrc

# Zsh
source <(scaffold --completions zsh)
scaffold --completions zsh >> ~/.zshrc

# Auto-detect from $SHELL
source <(scaffold --completions)
```

## Persistent Defaults (`.scaffoldrc`)

Save your preferences so future runs skip redundant prompts:

```bash
# Save after a scaffold run
scaffold --save-defaults

# Or create manually
cat > ~/.scaffoldrc <<'EOF'
LANGUAGE=python
ARCHETYPE=api
ENABLE_DOCKER=true
ENABLE_VSCODE=true
ALLOW_COMMIT=true
ALLOW_PUSH=false
EOF
```

Values in `~/.scaffoldrc` serve as defaults. CLI flags and interactive prompts still override them. In `--non-interactive` mode, `.scaffoldrc` values replace the built-in defaults.
