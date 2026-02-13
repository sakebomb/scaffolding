# Languages, Archetypes & Templates

## Supported Languages

| Language | Linter | Formatter | Type Checker | Test Runner | Config Files |
|----------|--------|-----------|-------------|-------------|-------------|
| Python | ruff | ruff | mypy | pytest | pyproject.toml, ruff.toml, conftest.py |
| TypeScript | eslint | eslint | tsc | vitest | package.json, tsconfig.json, eslint.config.mjs |
| Go | golangci-lint | gofmt | (built-in) | go test | go.mod |
| Rust | clippy | rustfmt | (built-in) | cargo test | Cargo.toml |
| None | — | — | — | — | (configure manually later) |

Language-specific conventions are appended to `CLAUDE.md` during init — covering linting, testing, project structure, and idiomatic patterns.

## Project Archetypes

After selecting a language, scaffold asks for a project archetype that generates starter files:

| Archetype | What It Generates |
|-----------|------------------|
| **CLI** | Entry point with argument parsing and subcommand structure |
| **API** | HTTP server with routes directory and health check endpoint |
| **Library** | Public module with exported functions, ready for distribution |
| **None** | Blank project with language tooling only (default) |

Each archetype is language-aware — a Python API uses stdlib `http.server`, a Go API uses `net/http`, a Rust CLI uses `std::env`, etc. No framework dependencies are added by default.

## Community Templates

You can create and share language templates beyond the four built-in ones.

### Template Structure

A valid template directory must contain at minimum:

```
templates/my-language/
├── CONVENTIONS.md        # Required — language conventions appended to CLAUDE.md
├── gitignore.append      # Required — entries appended to .gitignore
├── some-config.toml.tmpl # Optional — processed with placeholder replacement
├── other-config.json     # Optional — copied as-is
└── ...
```

### Placeholders

`.tmpl` files support two placeholders that are replaced during scaffold:

- `{{PROJECT_NAME}}` — the project name entered during init
- `{{PROJECT_DESCRIPTION}}` — the project description entered during init

Files without the `.tmpl` extension are copied as-is.

### `CONVENTIONS.md`

This file is appended to the project's `CLAUDE.md` during init. It should contain language-specific guidance for Claude Code:

- Project structure expectations
- Linter and formatter configuration
- Testing patterns and conventions
- Idiomatic patterns and anti-patterns
- Import ordering and style rules

See the built-in templates (`templates/python/CONVENTIONS.md`, etc.) for examples.

### Installing Templates

```bash
# From a git repository
scaffold --install-template https://github.com/user/scaffold-template-ruby

# From a local directory
scaffold --install-template ./my-template

# List all available templates
scaffold --list-templates
```

Templates are installed to `~/.scaffold/templates/<name>/` and become available in `--add` language selection and the interactive prompt.
