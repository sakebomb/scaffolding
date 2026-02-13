## Python Conventions

> Appended to CLAUDE.md during scaffold init. These are language-specific rules for Claude Code.

### Code Style

- **Type hints on all function signatures.** Use `from __future__ import annotations` for modern syntax.
- **Ruff for linting and formatting.** Run `ruff check .` and `ruff format .` — these replace flake8, isort, and black.
- **Docstrings on public functions and classes** — use Google-style docstrings. Skip docstrings on obvious one-liners and private helpers.
- **Import order**: stdlib → third-party → local. Ruff handles this automatically.
- **Prefer `pathlib.Path` over `os.path`** for file operations.
- **Prefer f-strings** over `.format()` or `%` for string formatting.
- **Use `dataclasses` or `pydantic` models** for structured data — avoid raw dicts for anything with a known schema.

### Error Handling

- **Catch specific exceptions** — never bare `except:` or `except Exception:` unless re-raising.
- **Use custom exception classes** for domain errors. Inherit from a project-level base exception.
- **Let unexpected exceptions propagate** — don't silently swallow errors.
- **Use `contextlib.suppress()`** for intentionally ignored exceptions (cleaner than try/except/pass).

### Testing

- **Framework**: pytest. Configuration lives in `pyproject.toml` under `[tool.pytest.ini_options]`.
- **Fixtures over setup/teardown.** Use `conftest.py` for shared fixtures.
- **Parametrize repetitive tests** with `@pytest.mark.parametrize`.
- **Mock external dependencies** with `unittest.mock` or `pytest-mock`. Never mock the code under test.
- **Test file naming**: `test_<module>.py` in the corresponding `tests/` subdirectory.

### Project Structure

```
project/
├── src/
│   └── {{PROJECT_NAME}}/
│       ├── __init__.py
│       └── ...
├── tests/
│   ├── unit/
│   ├── integration/
│   └── agent/
├── pyproject.toml
├── ruff.toml
└── conftest.py
```

### Dependencies

- **Define dependencies in `pyproject.toml`** — not requirements.txt (unless needed for compatibility).
- **Pin major versions** in dependencies (`>=1.0,<2.0`), exact versions in lock files.
- **Use virtual environments** — never install to system Python.
- **Separate dev dependencies** under `[project.optional-dependencies]` with a `dev` group.

### Performance

- **Use generators for large sequences** — `yield` instead of building lists.
- **Use `collections.defaultdict`**, `Counter`, and `deque` from stdlib before reaching for external libraries.
- **Profile before optimizing** — `cProfile` for CPU, `tracemalloc` for memory.
