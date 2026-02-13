# =============================================================================
# Makefile — Generic Test Runner & Development Tasks
# =============================================================================
# Designed to work with the CLAUDE.md testing framework (Section 5).
# Detects project language automatically. Override with: make test LANG=python
#
# Supported languages: python, typescript, go, rust
#
# Usage:
#   make test              Run full suite (all tiers, fail-fast)
#   make test-unit         Tier 1 — Unit tests only
#   make test-integration  Tier 2 — Integration tests only
#   make test-agent        Tier 3 — Agent behavior tests only
#   make test-file FILE=x  Run a single test file
#   make test-coverage     Full suite + coverage report
#   make lint              Run linter
#   make fmt               Run formatter
#   make typecheck         Run type checker
#   make build             Compile / build the project
#   make check             Lint + typecheck + full test suite (pre-PR gate)
# =============================================================================

# ---------------------------------------------------------------------------
# Language Detection (override with LANG=python|typescript|go|rust)
# ---------------------------------------------------------------------------
LANG ?= auto

ifeq ($(LANG),auto)
  ifneq (,$(wildcard Cargo.toml))
    DETECTED_LANG := rust
  else ifneq (,$(wildcard go.mod))
    DETECTED_LANG := go
  else ifneq (,$(wildcard tsconfig.json))
    DETECTED_LANG := typescript
  else ifneq (,$(wildcard package.json))
    DETECTED_LANG := typescript
  else ifneq (,$(wildcard pyproject.toml setup.py setup.cfg requirements.txt))
    DETECTED_LANG := python
  else
    DETECTED_LANG := python
  endif
else
  DETECTED_LANG := $(LANG)
endif

# ---------------------------------------------------------------------------
# Python Configuration
# ---------------------------------------------------------------------------
PYTHON_TEST_CMD     := python -m pytest
PYTHON_UNIT_DIR     := tests/unit
PYTHON_INT_DIR      := tests/integration
PYTHON_AGENT_DIR    := tests/agent
PYTHON_LINT_CMD     := python -m ruff check .
PYTHON_FMT_CMD      := python -m ruff format .
PYTHON_TYPE_CMD     := python -m mypy .
PYTHON_BUILD_CMD    := @echo "Python: no compilation needed"
PYTHON_COV_FLAGS    := --cov --cov-report=term-missing --cov-report=html:coverage_html
PYTHON_FILE_CMD     := python -m pytest

# ---------------------------------------------------------------------------
# TypeScript Configuration
# ---------------------------------------------------------------------------
TS_TEST_CMD         := npx vitest run
TS_UNIT_DIR         := tests/unit
TS_INT_DIR          := tests/integration
TS_AGENT_DIR        := tests/agent
TS_LINT_CMD         := npx eslint .
TS_FMT_CMD          := npx eslint . --fix
TS_TYPE_CMD         := npx tsc --noEmit
TS_BUILD_CMD        := npx tsc
TS_COV_FLAGS        := --coverage
TS_FILE_CMD         := npx vitest run

# ---------------------------------------------------------------------------
# Go Configuration
# ---------------------------------------------------------------------------
GO_TEST_CMD         := go test
GO_UNIT_DIR         := ./tests/unit/...
GO_INT_DIR          := ./tests/integration/...
GO_AGENT_DIR        := ./tests/agent/...
GO_LINT_CMD         := golangci-lint run
GO_FMT_CMD          := gofmt -w .
GO_TYPE_CMD         := @echo "Go: type checking included in build"
GO_BUILD_CMD        := go build ./...
GO_COV_FLAGS        := -coverprofile=coverage.out
GO_FILE_CMD         := go test

# ---------------------------------------------------------------------------
# Rust Configuration
# ---------------------------------------------------------------------------
RUST_TEST_CMD       := cargo test
RUST_UNIT_DIR       :=
RUST_INT_DIR        :=
RUST_AGENT_DIR      :=
RUST_LINT_CMD       := cargo clippy -- -D warnings
RUST_FMT_CMD        := cargo fmt
RUST_TYPE_CMD       := @echo "Rust: type checking included in build"
RUST_BUILD_CMD      := cargo build
RUST_COV_FLAGS      :=
RUST_FILE_CMD       := cargo test

# ---------------------------------------------------------------------------
# Resolve commands based on detected language
# ---------------------------------------------------------------------------
ifeq ($(DETECTED_LANG),python)
  TEST_CMD     := $(PYTHON_TEST_CMD)
  UNIT_DIR     := $(PYTHON_UNIT_DIR)
  INT_DIR      := $(PYTHON_INT_DIR)
  AGENT_DIR    := $(PYTHON_AGENT_DIR)
  LINT_CMD     := $(PYTHON_LINT_CMD)
  FMT_CMD      := $(PYTHON_FMT_CMD)
  TYPE_CMD     := $(PYTHON_TYPE_CMD)
  BUILD_CMD    := $(PYTHON_BUILD_CMD)
  COV_FLAGS    := $(PYTHON_COV_FLAGS)
  FILE_CMD     := $(PYTHON_FILE_CMD)
else ifeq ($(DETECTED_LANG),typescript)
  TEST_CMD     := $(TS_TEST_CMD)
  UNIT_DIR     := $(TS_UNIT_DIR)
  INT_DIR      := $(TS_INT_DIR)
  AGENT_DIR    := $(TS_AGENT_DIR)
  LINT_CMD     := $(TS_LINT_CMD)
  FMT_CMD      := $(TS_FMT_CMD)
  TYPE_CMD     := $(TS_TYPE_CMD)
  BUILD_CMD    := $(TS_BUILD_CMD)
  COV_FLAGS    := $(TS_COV_FLAGS)
  FILE_CMD     := $(TS_FILE_CMD)
else ifeq ($(DETECTED_LANG),go)
  TEST_CMD     := $(GO_TEST_CMD)
  UNIT_DIR     := $(GO_UNIT_DIR)
  INT_DIR      := $(GO_INT_DIR)
  AGENT_DIR    := $(GO_AGENT_DIR)
  LINT_CMD     := $(GO_LINT_CMD)
  FMT_CMD      := $(GO_FMT_CMD)
  TYPE_CMD     := $(GO_TYPE_CMD)
  BUILD_CMD    := $(GO_BUILD_CMD)
  COV_FLAGS    := $(GO_COV_FLAGS)
  FILE_CMD     := $(GO_FILE_CMD)
else ifeq ($(DETECTED_LANG),rust)
  TEST_CMD     := $(RUST_TEST_CMD)
  UNIT_DIR     := $(RUST_UNIT_DIR)
  INT_DIR      := $(RUST_INT_DIR)
  AGENT_DIR    := $(RUST_AGENT_DIR)
  LINT_CMD     := $(RUST_LINT_CMD)
  FMT_CMD      := $(RUST_FMT_CMD)
  TYPE_CMD     := $(RUST_TYPE_CMD)
  BUILD_CMD    := $(RUST_BUILD_CMD)
  COV_FLAGS    := $(RUST_COV_FLAGS)
  FILE_CMD     := $(RUST_FILE_CMD)
endif

# ---------------------------------------------------------------------------
# Common flags
# ---------------------------------------------------------------------------
VERBOSE ?=
ifeq ($(VERBOSE),1)
  V_FLAG := -v
else
  V_FLAG :=
endif

# ---------------------------------------------------------------------------
# Targets
# ---------------------------------------------------------------------------

.PHONY: test test-unit test-integration test-agent test-file test-coverage \
        lint fmt typecheck build check help

## Run full test suite: unit → integration → agent (fail-fast)
## For Rust: cargo test runs all tests; tiers are filtered by test name prefix
test:
	@echo "═══ Running Full Test Suite ($(DETECTED_LANG)) ═══"
ifeq ($(DETECTED_LANG),rust)
	@echo "--- Running all Rust tests ---"
	@$(TEST_CMD) $(V_FLAG) || (echo "❌ Tests failed." && exit 1)
else
	@echo "--- Tier 1: Unit Tests ---"
	@$(TEST_CMD) $(UNIT_DIR) $(V_FLAG) || (echo "❌ Unit tests failed — stopping." && exit 1)
	@echo "--- Tier 2: Integration Tests ---"
	@$(TEST_CMD) $(INT_DIR) $(V_FLAG) || (echo "❌ Integration tests failed — stopping." && exit 1)
	@echo "--- Tier 3: Agent Behavior Tests ---"
	@$(TEST_CMD) $(AGENT_DIR) $(V_FLAG) || (echo "❌ Agent behavior tests failed — stopping." && exit 1)
endif
	@echo "✅ All tiers passed."

## Tier 1: Unit tests only
test-unit:
	@echo "--- Tier 1: Unit Tests ($(DETECTED_LANG)) ---"
ifeq ($(DETECTED_LANG),rust)
	$(TEST_CMD) --lib $(V_FLAG)
else
	$(TEST_CMD) $(UNIT_DIR) $(V_FLAG)
endif

## Tier 2: Integration tests only
test-integration:
	@echo "--- Tier 2: Integration Tests ($(DETECTED_LANG)) ---"
ifeq ($(DETECTED_LANG),rust)
	$(TEST_CMD) --test '*' $(V_FLAG)
else
	$(TEST_CMD) $(INT_DIR) $(V_FLAG)
endif

## Tier 3: Agent behavior tests only
test-agent:
	@echo "--- Tier 3: Agent Behavior Tests ($(DETECTED_LANG)) ---"
ifeq ($(DETECTED_LANG),rust)
	$(TEST_CMD) --test 'agent_*' $(V_FLAG)
else
	$(TEST_CMD) $(AGENT_DIR) $(V_FLAG)
endif

## Run a single test file (usage: make test-file FILE=tests/unit/test_foo.py)
test-file:
ifndef FILE
	@echo "Usage: make test-file FILE=path/to/test_file"
	@exit 1
endif
	$(FILE_CMD) $(FILE) $(V_FLAG)

## Full suite with coverage report
test-coverage:
	@echo "═══ Running Full Suite + Coverage ($(DETECTED_LANG)) ═══"
ifeq ($(DETECTED_LANG),rust)
	$(TEST_CMD) $(COV_FLAGS) $(V_FLAG)
else
	$(TEST_CMD) $(UNIT_DIR) $(INT_DIR) $(AGENT_DIR) $(COV_FLAGS) $(V_FLAG)
endif

## Run linter
lint:
	@echo "--- Linting ($(DETECTED_LANG)) ---"
	$(LINT_CMD)

## Run formatter
fmt:
	@echo "--- Formatting ($(DETECTED_LANG)) ---"
	$(FMT_CMD)

## Run type checker
typecheck:
	@echo "--- Type Checking ($(DETECTED_LANG)) ---"
	$(TYPE_CMD)

## Compile / build the project
build:
	@echo "--- Building ($(DETECTED_LANG)) ---"
	$(BUILD_CMD)

## Pre-PR gate: lint + typecheck + full test suite
check: lint typecheck test
	@echo "✅ All checks passed — ready for PR."

## Show available targets
help:
	@echo "Available targets:"
	@echo "  make test              Full suite (unit → integration → agent, fail-fast)"
	@echo "  make test-unit         Tier 1 — Unit tests"
	@echo "  make test-integration  Tier 2 — Integration tests"
	@echo "  make test-agent        Tier 3 — Agent behavior tests"
	@echo "  make test-file FILE=x  Single test file"
	@echo "  make test-coverage     Full suite + coverage report"
	@echo "  make lint              Run linter"
	@echo "  make fmt               Run formatter"
	@echo "  make typecheck         Run type checker"
	@echo "  make build             Compile / build"
	@echo "  make check             Lint + typecheck + full suite (pre-PR gate)"
	@echo ""
	@echo "Options:"
	@echo "  LANG=python|typescript|go|rust  Override language detection"
	@echo "  VERBOSE=1                       Verbose test output"
	@echo ""
	@echo "Detected language: $(DETECTED_LANG)"
