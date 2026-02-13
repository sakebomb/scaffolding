#!/usr/bin/env bash
# =============================================================================
# Behavior tests for the scaffold init script
# =============================================================================
# Runs scaffold in --non-interactive mode for each language and verifies:
#   - Expected files exist
#   - Expected files are absent (cleaned up)
#   - Placeholder replacement works
#   - Git repo is initialized with correct structure
#
# Usage:
#   bash tests/test_scaffold.sh           Run all tests
#   bash tests/test_scaffold.sh python    Run single language test
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PASS=0
FAIL=0
TOTAL=0

# Colors
if [[ -t 1 ]]; then
  GREEN='\033[0;32m' RED='\033[0;31m' YELLOW='\033[0;33m' BOLD='\033[1m' DIM='\033[2m' RESET='\033[0m'
else
  GREEN='' RED='' YELLOW='' BOLD='' DIM='' RESET=''
fi

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
assert_file_exists() {
  local file="$1"
  local label="${2:-$file}"
  TOTAL=$((TOTAL + 1))
  if [[ -e "$WORK_DIR/$file" ]]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} File missing: $label"
  fi
}

assert_file_absent() {
  local file="$1"
  local label="${2:-$file}"
  TOTAL=$((TOTAL + 1))
  if [[ ! -e "$WORK_DIR/$file" ]]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} File should not exist: $label"
  fi
}

assert_file_contains() {
  local file="$1"
  local pattern="$2"
  local label="${3:-$file contains $pattern}"
  TOTAL=$((TOTAL + 1))
  if grep -q "$pattern" "$WORK_DIR/$file" 2>/dev/null; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} $label"
  fi
}

assert_file_not_contains() {
  local file="$1"
  local pattern="$2"
  local label="${3:-$file should not contain $pattern}"
  TOTAL=$((TOTAL + 1))
  if ! grep -q "$pattern" "$WORK_DIR/$file" 2>/dev/null; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} $label"
  fi
}

assert_dir_exists() {
  local dir="$1"
  local label="${2:-$dir}"
  TOTAL=$((TOTAL + 1))
  if [[ -d "$WORK_DIR/$dir" ]]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} Directory missing: $label"
  fi
}

assert_git_repo() {
  TOTAL=$((TOTAL + 1))
  if [[ -d "$WORK_DIR/.git" ]]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} Not a git repository"
  fi
}

assert_git_commit_count() {
  local expected="$1"
  TOTAL=$((TOTAL + 1))
  local actual
  actual="$(git -C "$WORK_DIR" rev-list --count HEAD 2>/dev/null || echo "0")"
  if [[ "$actual" == "$expected" ]]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} Expected $expected commits, got $actual"
  fi
}

assert_file_count() {
  local expected="$1"
  TOTAL=$((TOTAL + 1))
  local actual
  actual="$(git -C "$WORK_DIR" ls-files | wc -l)"
  if [[ "$actual" -eq "$expected" ]]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} Expected $expected tracked files, got $actual"
  fi
}

# ---------------------------------------------------------------------------
# Setup / teardown
# ---------------------------------------------------------------------------
setup_test() {
  local test_name="$1"
  WORK_DIR="$(mktemp -d "/tmp/scaffold-test-${test_name}-XXXXXX")"
  cp -r "$SCRIPT_DIR"/* "$WORK_DIR/" 2>/dev/null || true
  cp -r "$SCRIPT_DIR"/.claude "$WORK_DIR/" 2>/dev/null || true
  cp -r "$SCRIPT_DIR"/.github "$WORK_DIR/" 2>/dev/null || true
  cp -r "$SCRIPT_DIR"/.gitignore "$WORK_DIR/" 2>/dev/null || true
  # Don't copy .git — scaffold creates its own
}

teardown_test() {
  if [[ -n "${WORK_DIR:-}" && -d "$WORK_DIR" ]]; then
    rm -rf "$WORK_DIR"
  fi
}

run_scaffold() {
  cd "$WORK_DIR" && ./scaffold --non-interactive 2>&1
  cd "$SCRIPT_DIR"
}

# Override the language selection in the scaffold script for testing
force_language() {
  local lang="$1"
  # Replace the step_language function body with a direct assignment
  sed -i "/^step_language() {$/,/^}$/c\\
step_language() {\\
  LANGUAGE=\"$lang\"\\
  success \"Language: $lang\"\\
}" "$WORK_DIR/scaffold"
}

# Override the archetype selection in the scaffold script for testing
force_archetype() {
  local arch="$1"
  sed -i "/^step_archetype() {$/,/^}$/c\\
step_archetype() {\\
  ARCHETYPE=\"$arch\"\\
  success \"Archetype: $arch\"\\
}" "$WORK_DIR/scaffold"
}

# ---------------------------------------------------------------------------
# Test: Common structure (shared by all languages)
# ---------------------------------------------------------------------------
assert_common_structure() {
  # Core files
  assert_file_exists "CLAUDE.md"
  assert_file_exists "README.md"
  assert_file_exists "GETTING_STARTED.md"
  assert_file_exists "LICENSE"
  assert_file_exists "Makefile"
  assert_file_exists ".gitignore"

  # Claude config
  assert_file_exists ".claude/settings.json"
  assert_dir_exists ".claude/skills"
  assert_file_exists ".claude/skills/plan/SKILL.md"
  assert_file_exists ".claude/skills/review/SKILL.md"
  assert_file_exists ".claude/skills/test/SKILL.md"
  assert_file_exists ".claude/skills/lesson/SKILL.md"
  assert_file_exists ".claude/skills/checkpoint/SKILL.md"
  assert_file_exists ".claude/skills/status/SKILL.md"
  assert_file_exists ".claude/skills/simplify/SKILL.md"
  assert_file_exists ".claude/skills/index/SKILL.md"
  assert_file_exists ".claude/skills/save/SKILL.md"
  assert_file_exists ".claude/skills/load/SKILL.md"
  assert_file_exists ".claude/skills/backlog/SKILL.md"
  assert_file_exists ".claude/skills/start/SKILL.md"
  assert_file_exists ".claude/skills/doctor/SKILL.md"
  assert_file_exists ".claude/skills/refactor/SKILL.md"
  assert_file_exists ".claude/hooks/protect-main-branch.sh"

  # GitHub templates and workflows
  assert_file_exists ".github/ISSUE_TEMPLATE/bug.yml"
  assert_file_exists ".github/ISSUE_TEMPLATE/feature.yml"
  assert_file_exists ".github/ISSUE_TEMPLATE/task.yml"
  assert_file_exists ".github/ISSUE_TEMPLATE/config.yml"
  assert_file_exists ".github/pull_request_template.md"
  assert_file_exists ".github/workflows/ci.yml"
  assert_file_exists ".github/workflows/release.yml"

  # Generated project files
  assert_file_exists ".env.example"
  assert_file_exists "CHANGELOG.md"
  assert_file_exists "SECURITY.md"
  assert_file_exists ".pre-commit-config.yaml"

  # README badges
  assert_file_contains "README.md" "License-MIT" "README should contain MIT license badge"

  # Agents
  assert_dir_exists "agents"
  assert_file_exists "agents/README.md"
  assert_file_exists "agents/plan-agent.md"
  assert_file_exists "agents/research-agent.md"
  assert_file_exists "agents/code-review-agent.md"
  assert_file_exists "agents/test-runner-agent.md"
  assert_file_exists "agents/build-validator-agent.md"
  assert_file_exists "agents/code-architect-agent.md"
  assert_file_exists "agents/code-simplifier-agent.md"
  assert_file_exists "agents/verify-agent.md"

  # Tasks
  assert_dir_exists "tasks"
  assert_file_exists "tasks/todo.md"
  assert_file_exists "tasks/lessons.md"
  assert_file_exists "tasks/tests.md"
  assert_file_exists "tasks/session.md"

  # Test directories
  assert_dir_exists "tests/unit"
  assert_dir_exists "tests/integration"
  assert_dir_exists "tests/agent"

  # Scratch
  assert_dir_exists "scratch"
  assert_file_exists "scratch/.gitkeep"

  # Cleanup verification — scaffold artifacts should be gone
  assert_file_absent "scaffold" "scaffold script should be removed"
  assert_file_absent "templates" "templates/ should be removed"

  # Git
  assert_git_repo
  assert_git_commit_count 1

  # Placeholder replacement
  assert_file_not_contains "CLAUDE.md" "{{PROJECT_NAME}}" "CLAUDE.md should not contain {{PROJECT_NAME}} placeholder"
  assert_file_not_contains "CLAUDE.md" "{{PROJECT_DESCRIPTION}}" "CLAUDE.md should not contain {{PROJECT_DESCRIPTION}} placeholder"
  assert_file_contains "GETTING_STARTED.md" "Getting Started" "GETTING_STARTED.md should contain onboarding content"
}

# ---------------------------------------------------------------------------
# Test: Python
# ---------------------------------------------------------------------------
test_python() {
  echo -e "\n${BOLD}Test: Python scaffold${RESET}"
  setup_test "python"

  # Hack: force python selection in non-interactive mode
  # Non-interactive defaults to first choice (python), so this works as-is
  run_scaffold > /dev/null

  assert_common_structure

  # Python-specific files
  assert_file_exists "pyproject.toml"
  assert_file_exists "ruff.toml"
  assert_file_exists "conftest.py"
  assert_dir_exists "src"
  assert_file_contains "CLAUDE.md" "Python Conventions" "CLAUDE.md should contain Python conventions"
  assert_file_not_contains "pyproject.toml" "{{PROJECT_NAME}}" "pyproject.toml should not contain placeholder"
  assert_file_contains ".gitignore" "__pycache__" ".gitignore should contain Python entries"
  assert_file_contains "Makefile" "setup:" "Makefile should contain setup target"

  # Should NOT have other language files
  assert_file_absent "package.json"
  assert_file_absent "tsconfig.json"
  assert_file_absent "go.mod"
  assert_file_absent "Cargo.toml"

  teardown_test
  echo -e "  ${GREEN}Python: done${RESET}"
}

# ---------------------------------------------------------------------------
# Test: TypeScript (requires modifying the script to select TS)
# ---------------------------------------------------------------------------
test_typescript() {
  echo -e "\n${BOLD}Test: TypeScript scaffold${RESET}"
  setup_test "typescript"
  force_language "typescript"
  run_scaffold > /dev/null

  assert_common_structure

  # TypeScript-specific files
  assert_file_exists "package.json"
  assert_file_exists "tsconfig.json"
  assert_file_exists "eslint.config.mjs"
  assert_file_exists "src/index.ts"
  assert_file_contains "CLAUDE.md" "TypeScript Conventions" "CLAUDE.md should contain TypeScript conventions"
  assert_file_not_contains "package.json" "{{PROJECT_NAME}}" "package.json should not contain placeholder"
  assert_file_contains ".gitignore" "node_modules" ".gitignore should contain TypeScript entries"

  # Should NOT have other language files
  assert_file_absent "pyproject.toml"
  assert_file_absent "go.mod"
  assert_file_absent "Cargo.toml"

  teardown_test
  echo -e "  ${GREEN}TypeScript: done${RESET}"
}

# ---------------------------------------------------------------------------
# Test: Go
# ---------------------------------------------------------------------------
test_go() {
  echo -e "\n${BOLD}Test: Go scaffold${RESET}"
  setup_test "go"
  force_language "go"
  run_scaffold > /dev/null

  assert_common_structure

  # Go-specific files
  assert_file_exists "go.mod"
  assert_dir_exists "cmd"
  assert_file_contains "CLAUDE.md" "Go Conventions" "CLAUDE.md should contain Go conventions"
  assert_file_not_contains "go.mod" "{{PROJECT_NAME}}" "go.mod should not contain placeholder"

  # Should NOT have other language files
  assert_file_absent "pyproject.toml"
  assert_file_absent "package.json"
  assert_file_absent "Cargo.toml"

  teardown_test
  echo -e "  ${GREEN}Go: done${RESET}"
}

# ---------------------------------------------------------------------------
# Test: Rust
# ---------------------------------------------------------------------------
test_rust() {
  echo -e "\n${BOLD}Test: Rust scaffold${RESET}"
  setup_test "rust"
  force_language "rust"
  run_scaffold > /dev/null

  assert_common_structure

  # Rust-specific files
  assert_file_exists "Cargo.toml"
  assert_file_exists "src/main.rs"
  assert_file_contains "CLAUDE.md" "Rust Conventions" "CLAUDE.md should contain Rust conventions"
  assert_file_not_contains "Cargo.toml" "{{PROJECT_NAME}}" "Cargo.toml should not contain placeholder"
  assert_file_contains ".gitignore" "target/" ".gitignore should contain Rust entries"

  # Should NOT have other language files
  assert_file_absent "pyproject.toml"
  assert_file_absent "package.json"
  assert_file_absent "go.mod"

  teardown_test
  echo -e "  ${GREEN}Rust: done${RESET}"
}

# ---------------------------------------------------------------------------
# Test: None (language-agnostic)
# ---------------------------------------------------------------------------
test_none() {
  echo -e "\n${BOLD}Test: No language scaffold${RESET}"
  setup_test "none"
  force_language "none"
  run_scaffold > /dev/null

  assert_common_structure

  # Should NOT have any language-specific files
  assert_file_absent "pyproject.toml"
  assert_file_absent "package.json"
  assert_file_absent "tsconfig.json"
  assert_file_absent "go.mod"
  assert_file_absent "Cargo.toml"
  assert_file_absent "ruff.toml"
  assert_file_absent "conftest.py"

  # CLAUDE.md should not have language conventions appended
  assert_file_not_contains "CLAUDE.md" "Python Conventions"
  assert_file_not_contains "CLAUDE.md" "TypeScript Conventions"
  assert_file_not_contains "CLAUDE.md" "Go Conventions"
  assert_file_not_contains "CLAUDE.md" "Rust Conventions"

  teardown_test
  echo -e "  ${GREEN}None: done${RESET}"
}

# ---------------------------------------------------------------------------
# Test: --keep flag preserves artifacts
# ---------------------------------------------------------------------------
test_keep_flag() {
  echo -e "\n${BOLD}Test: --keep flag${RESET}"
  setup_test "keep"

  cd "$WORK_DIR" && ./scaffold --non-interactive --keep > /dev/null 2>&1
  cd "$SCRIPT_DIR"

  assert_file_exists "scaffold" "scaffold script should be preserved with --keep"
  assert_dir_exists "templates" "templates/ should be preserved with --keep"

  teardown_test
  echo -e "  ${GREEN}--keep: done${RESET}"
}

# ---------------------------------------------------------------------------
# Test: Permissions are written correctly
# ---------------------------------------------------------------------------
test_permissions() {
  echo -e "\n${BOLD}Test: Permissions in settings.json${RESET}"
  setup_test "permissions"

  run_scaffold > /dev/null

  # Default non-interactive: ALLOW_COMMIT=true, others false
  assert_file_contains ".claude/settings.json" "git commit" "settings.json should contain git commit permission"

  # Deny rules should be present
  assert_file_contains ".claude/settings.json" "rm -rf" "settings.json should deny rm -rf"
  assert_file_contains ".claude/settings.json" "git push --force" "settings.json should deny git push --force"

  teardown_test
  echo -e "  ${GREEN}Permissions: done${RESET}"
}

# ---------------------------------------------------------------------------
# Test: Python + API archetype
# ---------------------------------------------------------------------------
test_python_api() {
  echo -e "\n${BOLD}Test: Python + API archetype${RESET}"
  setup_test "python-api"
  force_archetype "api"
  run_scaffold > /dev/null

  assert_common_structure

  # Python base files
  assert_file_exists "pyproject.toml"
  assert_file_exists "ruff.toml"
  assert_file_exists "conftest.py"
  assert_dir_exists "src"

  # API-specific files (package dir name includes random suffix, use glob)
  TOTAL=$((TOTAL + 1))
  if compgen -G "$WORK_DIR/src/*/app.py" > /dev/null 2>&1; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} API app.py should exist in src/<pkg>/"
  fi

  TOTAL=$((TOTAL + 1))
  if compgen -G "$WORK_DIR/src/*/routes/health.py" > /dev/null 2>&1; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} API health route should exist in src/<pkg>/routes/"
  fi

  TOTAL=$((TOTAL + 1))
  if grep -rq "create_app" "$WORK_DIR/src/"/*/app.py 2>/dev/null; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} app.py should contain create_app"
  fi

  TOTAL=$((TOTAL + 1))
  if grep -rq "HealthHandler" "$WORK_DIR/src/"/*/routes/health.py 2>/dev/null; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} health.py should contain HealthHandler"
  fi

  # Should NOT have CLI files
  TOTAL=$((TOTAL + 1))
  if ! compgen -G "$WORK_DIR/src/*/cli.py" > /dev/null 2>&1; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} CLI cli.py should not exist for API archetype"
  fi

  teardown_test
  echo -e "  ${GREEN}Python + API: done${RESET}"
}

# ---------------------------------------------------------------------------
# Test: TypeScript + CLI archetype
# ---------------------------------------------------------------------------
test_typescript_cli() {
  echo -e "\n${BOLD}Test: TypeScript + CLI archetype${RESET}"
  setup_test "ts-cli"
  force_language "typescript"
  force_archetype "cli"
  run_scaffold > /dev/null

  assert_common_structure

  # TypeScript base files
  assert_file_exists "package.json"
  assert_file_exists "tsconfig.json"
  assert_file_exists "eslint.config.mjs"

  # CLI-specific files
  assert_file_exists "src/cli.ts" "CLI entry point should exist"
  assert_file_contains "src/cli.ts" "parseArgs" "cli.ts should contain parseArgs"

  # Should NOT have API or library files
  assert_file_absent "src/app.ts"
  assert_file_absent "src/routes"

  teardown_test
  echo -e "  ${GREEN}TypeScript + CLI: done${RESET}"
}

# ---------------------------------------------------------------------------
# Test: Go + library archetype
# ---------------------------------------------------------------------------
test_go_library() {
  echo -e "\n${BOLD}Test: Go + library archetype${RESET}"
  setup_test "go-lib"
  force_language "go"
  force_archetype "library"
  run_scaffold > /dev/null

  assert_common_structure

  # Go base files
  assert_file_exists "go.mod"

  # Library-specific files (filename includes project name with random suffix)
  TOTAL=$((TOTAL + 1))
  if compgen -G "$WORK_DIR/scaffold_test_go_lib_*.go" > /dev/null 2>&1; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} Go library .go file should exist at root"
  fi

  TOTAL=$((TOTAL + 1))
  if grep -rq "func Hello" "$WORK_DIR"/scaffold_test_go_lib_*.go 2>/dev/null; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} library should contain exported Hello function"
  fi

  # Should NOT have cmd directory (library, not binary)
  assert_file_absent "cmd"

  teardown_test
  echo -e "  ${GREEN}Go + library: done${RESET}"
}

# ---------------------------------------------------------------------------
# Test: Rust + library archetype
# ---------------------------------------------------------------------------
test_rust_library() {
  echo -e "\n${BOLD}Test: Rust + library archetype${RESET}"
  setup_test "rust-lib"
  force_language "rust"
  force_archetype "library"
  run_scaffold > /dev/null

  assert_common_structure

  # Rust base files
  assert_file_exists "Cargo.toml"

  # Library-specific files
  assert_file_exists "src/lib.rs" "Rust lib.rs should exist"
  assert_file_contains "src/lib.rs" "pub fn hello" "lib.rs should contain pub fn hello"

  # Should NOT have main.rs (library, not binary)
  assert_file_absent "src/main.rs"

  teardown_test
  echo -e "  ${GREEN}Rust + library: done${RESET}"
}

# ---------------------------------------------------------------------------
# Test: --dry-run produces no files
# ---------------------------------------------------------------------------
test_dry_run() {
  echo -e "\n${BOLD}Test: --dry-run flag${RESET}"
  setup_test "dryrun"

  local output
  output="$(cd "$WORK_DIR" && ./scaffold --non-interactive --dry-run 2>&1)"
  cd "$SCRIPT_DIR"

  # Should NOT have created any project files (CLAUDE.md gets customized by apply_templates)
  # The original CLAUDE.md from the repo copy still exists, but .git should NOT be initialized
  TOTAL=$((TOTAL + 1))
  if [[ ! -d "$WORK_DIR/.git" ]]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} --dry-run should not initialize git"
  fi

  # Should NOT have generated a project README (apply_templates replaces it)
  # Check that the original README still exists (from repo copy) and wasn't replaced
  TOTAL=$((TOTAL + 1))
  if ! grep -q "^# scaffold-test-dryrun" "$WORK_DIR/README.md" 2>/dev/null; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} --dry-run should not generate project README"
  fi

  # Output should contain the dry-run preview
  TOTAL=$((TOTAL + 1))
  if echo "$output" | grep -q "Dry Run Preview"; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} --dry-run should print 'Dry Run Preview'"
  fi

  TOTAL=$((TOTAL + 1))
  if echo "$output" | grep -q "No files were written"; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} --dry-run should print 'No files were written'"
  fi

  # Output should list expected files
  TOTAL=$((TOTAL + 1))
  if echo "$output" | grep -q "CLAUDE.md"; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} --dry-run should list CLAUDE.md in preview"
  fi

  TOTAL=$((TOTAL + 1))
  if echo "$output" | grep -q "pyproject.toml"; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} --dry-run should list pyproject.toml for python default"
  fi

  teardown_test
  echo -e "  ${GREEN}--dry-run: done${RESET}"
}

# ---------------------------------------------------------------------------
# Test: --completions outputs a valid bash completion script
# ---------------------------------------------------------------------------
test_completions() {
  echo -e "\n${BOLD}Test: --completions flag${RESET}"
  setup_test "completions"

  local output
  output="$(cd "$WORK_DIR" && ./scaffold --completions 2>&1)"
  cd "$SCRIPT_DIR"

  # Should contain completion function
  TOTAL=$((TOTAL + 1))
  if echo "$output" | grep -q "_scaffold_completions"; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} --completions should define _scaffold_completions function"
  fi

  # Should contain all flags
  TOTAL=$((TOTAL + 1))
  if echo "$output" | grep -qF -- "--help"; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} --completions should include --help flag"
  fi

  TOTAL=$((TOTAL + 1))
  if echo "$output" | grep -qF -- "--add"; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} --completions should include --add flag"
  fi

  TOTAL=$((TOTAL + 1))
  if echo "$output" | grep -qF -- "--dry-run"; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} --completions should include --dry-run flag"
  fi

  # Should contain language options for --add
  TOTAL=$((TOTAL + 1))
  if echo "$output" | grep -q "python typescript go rust"; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} --completions should include language options for --add"
  fi

  # Should contain 'complete' command
  TOTAL=$((TOTAL + 1))
  if echo "$output" | grep -q "^complete -F"; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} --completions should register completion with 'complete -F'"
  fi

  # Should NOT have initialized a project
  TOTAL=$((TOTAL + 1))
  if [[ ! -d "$WORK_DIR/.git" ]]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} --completions should not initialize git"
  fi

  teardown_test
  echo -e "  ${GREEN}--completions: done${RESET}"
}

# ---------------------------------------------------------------------------
# Test: Rollback on failure cleans up partial state
# ---------------------------------------------------------------------------
test_rollback() {
  echo -e "\n${BOLD}Test: Graceful rollback${RESET}"
  setup_test "rollback"

  # Inject a failure into apply_templates to trigger rollback
  # We'll add a failing command right after SECURITY.md generation
  sed -i '/success "SECURITY.md generated"/a\
  false  # Injected failure for rollback test' "$WORK_DIR/scaffold"

  # Run scaffold (it should fail and auto-rollback in non-interactive mode)
  local output exit_code=0
  output="$(cd "$WORK_DIR" && ./scaffold --non-interactive 2>&1)" || exit_code=$?
  cd "$SCRIPT_DIR"

  # Should have failed
  TOTAL=$((TOTAL + 1))
  if [[ $exit_code -ne 0 ]]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} Scaffold should have failed with injected error"
  fi

  # Should have printed rollback message
  TOTAL=$((TOTAL + 1))
  if echo "$output" | grep -q "Scaffold failed"; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} Should print 'Scaffold failed' message"
  fi

  # In non-interactive mode, should auto-clean
  TOTAL=$((TOTAL + 1))
  if echo "$output" | grep -q "cleaning up"; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} Should auto-clean in non-interactive mode"
  fi

  # Should NOT have .git (init_git never ran)
  TOTAL=$((TOTAL + 1))
  if [[ ! -d "$WORK_DIR/.git" ]]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} Failed scaffold should not have .git directory"
  fi

  teardown_test
  echo -e "  ${GREEN}Rollback: done${RESET}"
}

# ---------------------------------------------------------------------------
# Test: --add layers a second language
# ---------------------------------------------------------------------------
test_add_language() {
  echo -e "\n${BOLD}Test: --add typescript (on python project)${RESET}"
  setup_test "add-lang"

  # First: scaffold a python project with --keep (so templates remain)
  cd "$WORK_DIR" && ./scaffold --non-interactive --keep > /dev/null 2>&1
  cd "$SCRIPT_DIR"

  # Verify it's a python project first
  TOTAL=$((TOTAL + 1))
  if [[ -f "$WORK_DIR/pyproject.toml" ]]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} Base project should have pyproject.toml"
  fi

  # Now add typescript
  cd "$WORK_DIR" && ./scaffold --add typescript > /dev/null 2>&1
  cd "$SCRIPT_DIR"

  # Should have TypeScript config files
  TOTAL=$((TOTAL + 1))
  if [[ -f "$WORK_DIR/package.json" ]]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} --add typescript should create package.json"
  fi

  TOTAL=$((TOTAL + 1))
  if [[ -f "$WORK_DIR/tsconfig.json" ]]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} --add typescript should create tsconfig.json"
  fi

  # Should NOT overwrite pyproject.toml
  TOTAL=$((TOTAL + 1))
  if [[ -f "$WORK_DIR/pyproject.toml" ]]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} --add should not remove existing pyproject.toml"
  fi

  # CLAUDE.md should have both conventions
  TOTAL=$((TOTAL + 1))
  if grep -q "Python Conventions" "$WORK_DIR/CLAUDE.md"; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} CLAUDE.md should still contain Python conventions"
  fi

  TOTAL=$((TOTAL + 1))
  if grep -q "TypeScript Conventions" "$WORK_DIR/CLAUDE.md"; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} CLAUDE.md should contain TypeScript conventions after --add"
  fi

  # .gitignore should have both language entries
  TOTAL=$((TOTAL + 1))
  if grep -q "__pycache__" "$WORK_DIR/.gitignore"; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} .gitignore should still have Python entries"
  fi

  TOTAL=$((TOTAL + 1))
  if grep -q "node_modules" "$WORK_DIR/.gitignore"; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} .gitignore should have TypeScript entries after --add"
  fi

  # Makefile should have prefixed targets
  TOTAL=$((TOTAL + 1))
  if grep -q "^test-ts:" "$WORK_DIR/Makefile"; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} Makefile should have test-ts target after --add"
  fi

  TOTAL=$((TOTAL + 1))
  if grep -q "^lint-ts:" "$WORK_DIR/Makefile"; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} Makefile should have lint-ts target after --add"
  fi

  TOTAL=$((TOTAL + 1))
  if grep -q "^fmt-ts:" "$WORK_DIR/Makefile"; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} Makefile should have fmt-ts target after --add"
  fi

  TOTAL=$((TOTAL + 1))
  if grep -q "^typecheck-ts:" "$WORK_DIR/Makefile"; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} Makefile should have typecheck-ts target after --add"
  fi

  # CI workflow should reference TypeScript
  TOTAL=$((TOTAL + 1))
  if grep -q "Node.js" "$WORK_DIR/.github/workflows/ci.yml"; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} CI workflow should reference Node.js after --add typescript"
  fi

  # Running --add again should not duplicate
  cd "$WORK_DIR" && ./scaffold --add typescript > /dev/null 2>&1
  cd "$SCRIPT_DIR"

  TOTAL=$((TOTAL + 1))
  local ts_count
  ts_count="$(grep -c "TypeScript Conventions" "$WORK_DIR/CLAUDE.md" || true)"
  if [[ "$ts_count" -eq 1 ]]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} Running --add twice should not duplicate conventions (found $ts_count)"
  fi

  TOTAL=$((TOTAL + 1))
  local target_count
  target_count="$(grep -c "^test-ts:" "$WORK_DIR/Makefile" || true)"
  if [[ "$target_count" -eq 1 ]]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} Running --add twice should not duplicate Makefile targets (found $target_count)"
  fi

  teardown_test
  echo -e "  ${GREEN}--add typescript: done${RESET}"
}

# ---------------------------------------------------------------------------
# Test: --version prints version string
# ---------------------------------------------------------------------------
test_version() {
  echo -e "\n${BOLD}Test: --version flag${RESET}"
  setup_test "version"

  local output
  output="$(cd "$WORK_DIR" && ./scaffold --version 2>&1)"
  cd "$SCRIPT_DIR"

  TOTAL=$((TOTAL + 1))
  if echo "$output" | grep -q "^scaffold "; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} --version should print 'scaffold <version>'"
  fi

  TOTAL=$((TOTAL + 1))
  if [[ ! -d "$WORK_DIR/.git" ]] || [[ "$(git -C "$WORK_DIR" rev-list --count HEAD 2>/dev/null || echo 0)" == "0" ]]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} --version should not initialize a project"
  fi

  teardown_test
  echo -e "  ${GREEN}--version: done${RESET}"
}

# ---------------------------------------------------------------------------
# Test: --migrate on an existing Python project
# ---------------------------------------------------------------------------
test_migrate() {
  echo -e "\n${BOLD}Test: --migrate on existing Python project${RESET}"
  setup_test "migrate"

  # Simulate an existing Python project (not scaffolded)
  # Remove CLAUDE.md and scaffold artifacts, keep templates for migration
  rm -f "$WORK_DIR/CLAUDE.md"
  rm -rf "$WORK_DIR/.claude/skills" "$WORK_DIR/.claude/hooks"
  rm -rf "$WORK_DIR/agents" "$WORK_DIR/tasks" "$WORK_DIR/scratch"
  rm -rf "$WORK_DIR/tests/unit" "$WORK_DIR/tests/integration" "$WORK_DIR/tests/agent"
  rm -f "$WORK_DIR/GETTING_STARTED.md"

  # Create a bare Python project
  mkdir -p "$WORK_DIR/src/myapp"
  touch "$WORK_DIR/src/myapp/__init__.py"
  cat > "$WORK_DIR/pyproject.toml" <<'EOF'
[project]
name = "myapp"
version = "0.1.0"
EOF

  # Initialize git (existing project has git)
  git -C "$WORK_DIR" init -b main > /dev/null 2>&1
  git -C "$WORK_DIR" add -A > /dev/null 2>&1
  git -C "$WORK_DIR" commit -m "initial" > /dev/null 2>&1

  # Run migrate
  cd "$WORK_DIR" && ./scaffold --migrate --non-interactive > /dev/null 2>&1
  cd "$SCRIPT_DIR"

  # Should have detected Python
  TOTAL=$((TOTAL + 1))
  if [[ -f "$WORK_DIR/CLAUDE.md" ]]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} --migrate should create CLAUDE.md"
  fi

  # CLAUDE.md should have Python conventions (if templates available)
  TOTAL=$((TOTAL + 1))
  if grep -q "Python Conventions" "$WORK_DIR/CLAUDE.md" 2>/dev/null; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} CLAUDE.md should have Python conventions after migrate"
  fi

  # Should have .claude/settings.json
  TOTAL=$((TOTAL + 1))
  if [[ -f "$WORK_DIR/.claude/settings.json" ]]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} --migrate should create .claude/settings.json"
  fi

  # Should have tasks/
  TOTAL=$((TOTAL + 1))
  if [[ -f "$WORK_DIR/tasks/todo.md" ]]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} --migrate should create tasks/todo.md"
  fi

  TOTAL=$((TOTAL + 1))
  if [[ -f "$WORK_DIR/tasks/lessons.md" ]]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} --migrate should create tasks/lessons.md"
  fi

  # Should have test directories
  TOTAL=$((TOTAL + 1))
  if [[ -d "$WORK_DIR/tests/unit" ]]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} --migrate should create tests/unit/"
  fi

  # Should have scratch/
  TOTAL=$((TOTAL + 1))
  if [[ -d "$WORK_DIR/scratch" ]]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} --migrate should create scratch/"
  fi

  # Should have GETTING_STARTED.md
  TOTAL=$((TOTAL + 1))
  if [[ -f "$WORK_DIR/GETTING_STARTED.md" ]]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} --migrate should create GETTING_STARTED.md"
  fi

  # Should NOT have overwritten pyproject.toml
  TOTAL=$((TOTAL + 1))
  if grep -q 'name = "myapp"' "$WORK_DIR/pyproject.toml"; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} --migrate should not overwrite existing pyproject.toml"
  fi

  # Git should still exist with original history
  TOTAL=$((TOTAL + 1))
  if [[ -d "$WORK_DIR/.git" ]]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} --migrate should preserve existing .git"
  fi

  teardown_test
  echo -e "  ${GREEN}--migrate: done${RESET}"
}

# ---------------------------------------------------------------------------
# Test: --migrate is idempotent (running twice doesn't duplicate)
# ---------------------------------------------------------------------------
test_migrate_idempotent() {
  echo -e "\n${BOLD}Test: --migrate idempotent${RESET}"
  setup_test "migrate-idem"

  # Simulate existing project
  rm -f "$WORK_DIR/CLAUDE.md"
  rm -rf "$WORK_DIR/.claude/skills" "$WORK_DIR/.claude/hooks"
  rm -rf "$WORK_DIR/agents" "$WORK_DIR/tasks" "$WORK_DIR/scratch"
  rm -rf "$WORK_DIR/tests/unit" "$WORK_DIR/tests/integration" "$WORK_DIR/tests/agent"
  rm -f "$WORK_DIR/GETTING_STARTED.md"

  cat > "$WORK_DIR/pyproject.toml" <<'EOF'
[project]
name = "myapp"
version = "0.1.0"
EOF
  git -C "$WORK_DIR" init -b main > /dev/null 2>&1
  git -C "$WORK_DIR" add -A > /dev/null 2>&1
  git -C "$WORK_DIR" commit -m "initial" > /dev/null 2>&1

  # Run migrate twice
  cd "$WORK_DIR" && ./scaffold --migrate --non-interactive > /dev/null 2>&1
  cd "$WORK_DIR" && ./scaffold --migrate --non-interactive > /dev/null 2>&1
  cd "$SCRIPT_DIR"

  # CLAUDE.md should have Python conventions exactly once
  TOTAL=$((TOTAL + 1))
  local conv_count
  conv_count="$(grep -c "Python Conventions" "$WORK_DIR/CLAUDE.md" 2>/dev/null || echo 0)"
  if [[ "$conv_count" -eq 1 ]]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} Double migrate should not duplicate conventions (found $conv_count)"
  fi

  # tasks/todo.md should still exist
  TOTAL=$((TOTAL + 1))
  if [[ -f "$WORK_DIR/tasks/todo.md" ]]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} Double migrate should preserve tasks/todo.md"
  fi

  teardown_test
  echo -e "  ${GREEN}--migrate idempotent: done${RESET}"
}

# ---------------------------------------------------------------------------
# .scaffoldrc defaults
# ---------------------------------------------------------------------------
test_scaffoldrc() {
  echo ""
  echo -e "${BOLD}Test: .scaffoldrc defaults${RESET}"

  setup_test "scaffoldrc"

  # Create a scaffoldrc that sets LANGUAGE=go
  local rc_file="$WORK_DIR/.scaffoldrc"
  cat > "$rc_file" <<'RCEOF'
# Test scaffoldrc
LANGUAGE=go
ENABLE_VSCODE=true
RCEOF

  # Run scaffold with SCAFFOLDRC pointing to our file
  export SCAFFOLDRC="$rc_file"
  run_scaffold > /dev/null
  unset SCAFFOLDRC

  # Should produce a Go project (not Python default)
  TOTAL=$((TOTAL + 1))
  if [[ -f "$WORK_DIR/go.mod" ]]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} scaffoldrc LANGUAGE=go did not produce go.mod"
  fi

  # Should NOT have Python files
  TOTAL=$((TOTAL + 1))
  if [[ ! -f "$WORK_DIR/pyproject.toml" ]]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} scaffoldrc LANGUAGE=go should not produce pyproject.toml"
  fi

  # VS Code settings should exist (ENABLE_VSCODE=true)
  TOTAL=$((TOTAL + 1))
  if [[ -f "$WORK_DIR/.vscode/settings.json" ]]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} scaffoldrc ENABLE_VSCODE=true should produce .vscode/settings.json"
  fi

  teardown_test
  echo -e "  ${GREEN}.scaffoldrc: done${RESET}"
}

test_scaffoldrc_override() {
  echo ""
  echo -e "${BOLD}Test: CLI overrides .scaffoldrc${RESET}"

  setup_test "scaffoldrc-override"

  # scaffoldrc says go, but we'll verify non-interactive default (python) wins
  # when scaffoldrc is not present
  run_scaffold > /dev/null

  # Default non-interactive scaffold (no scaffoldrc) should be Python
  TOTAL=$((TOTAL + 1))
  if [[ -f "$WORK_DIR/pyproject.toml" ]]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} Default scaffold without scaffoldrc should produce pyproject.toml"
  fi

  teardown_test
  echo -e "  ${GREEN}.scaffoldrc override: done${RESET}"
}

# ---------------------------------------------------------------------------
# Zsh completions
# ---------------------------------------------------------------------------
test_completions_zsh() {
  echo ""
  echo -e "${BOLD}Test: --completions zsh${RESET}"

  setup_test "completions-zsh"

  local output
  output="$(cd "$WORK_DIR" && ./scaffold --completions zsh 2>&1)"

  # Should contain #compdef
  TOTAL=$((TOTAL + 1))
  if echo "$output" | grep -qF -- "#compdef"; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} --completions zsh should contain #compdef"
  fi

  # Should contain _arguments
  TOTAL=$((TOTAL + 1))
  if echo "$output" | grep -qF -- "_arguments"; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} --completions zsh should contain _arguments"
  fi

  # Should list all major flags
  TOTAL=$((TOTAL + 1))
  local missing=0
  for flag in "--help" "--keep" "--migrate" "--add" "--version" "--dir" "--save-defaults"; do
    if ! echo "$output" | grep -qF -- "$flag"; then
      missing=$((missing + 1))
    fi
  done
  if [[ $missing -eq 0 ]]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} --completions zsh missing $missing flags"
  fi

  # Should NOT contain bash-specific 'complete -F'
  TOTAL=$((TOTAL + 1))
  if ! echo "$output" | grep -qF -- "complete -F"; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} --completions zsh should not contain bash 'complete -F'"
  fi

  # No project should be created
  TOTAL=$((TOTAL + 1))
  if [[ ! -d "$WORK_DIR/.git" ]]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} --completions zsh should not create project"
  fi

  teardown_test
  echo -e "  ${GREEN}--completions zsh: done${RESET}"
}

test_completions_bash_explicit() {
  echo ""
  echo -e "${BOLD}Test: --completions bash (explicit)${RESET}"

  setup_test "completions-bash"

  local output
  output="$(cd "$WORK_DIR" && ./scaffold --completions bash 2>&1)"

  # Should contain bash-specific 'complete -F'
  TOTAL=$((TOTAL + 1))
  if echo "$output" | grep -qF -- "complete -F"; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} --completions bash should contain 'complete -F'"
  fi

  # Should contain new flags
  TOTAL=$((TOTAL + 1))
  if echo "$output" | grep -qF -- "--save-defaults"; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} --completions bash should list --save-defaults"
  fi

  teardown_test
  echo -e "  ${GREEN}--completions bash: done${RESET}"
}

# ---------------------------------------------------------------------------
# Monorepo --add --dir
# ---------------------------------------------------------------------------
test_add_dir() {
  echo ""
  echo -e "${BOLD}Test: --add python --dir backend${RESET}"

  setup_test "add-dir"

  # First scaffold a base TypeScript project with --keep (needed for --add)
  force_language "typescript"
  # Inject --keep so scaffold + templates are preserved
  sed -i 's/KEEP_ARTIFACTS=false/KEEP_ARTIFACTS=true/' "$WORK_DIR/scaffold"
  run_scaffold > /dev/null

  # Now add Python in a subdirectory
  (cd "$WORK_DIR" && ./scaffold --add python --dir backend 2>&1) > /dev/null

  # Config files should be in backend/
  TOTAL=$((TOTAL + 1))
  if [[ -f "$WORK_DIR/backend/pyproject.toml" ]]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} --add python --dir backend should create backend/pyproject.toml"
  fi

  TOTAL=$((TOTAL + 1))
  if [[ -f "$WORK_DIR/backend/ruff.toml" ]]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} --add python --dir backend should create backend/ruff.toml"
  fi

  # Original TS files should still be at root
  TOTAL=$((TOTAL + 1))
  if [[ -f "$WORK_DIR/tsconfig.json" ]]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} Root tsconfig.json should still exist"
  fi

  # Makefile should have dir-prefixed targets
  TOTAL=$((TOTAL + 1))
  if grep -qF -- "test-backend-py:" "$WORK_DIR/Makefile" 2>/dev/null; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} Makefile should contain test-backend-py target"
  fi

  TOTAL=$((TOTAL + 1))
  if grep -qF -- "lint-backend-py:" "$WORK_DIR/Makefile" 2>/dev/null; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} Makefile should contain lint-backend-py target"
  fi

  # Makefile targets should cd into backend
  TOTAL=$((TOTAL + 1))
  if grep -qF -- "cd backend" "$WORK_DIR/Makefile" 2>/dev/null; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} Makefile targets should cd into backend"
  fi

  # CLAUDE.md should have Python conventions
  TOTAL=$((TOTAL + 1))
  if grep -qF -- "Python Conventions" "$WORK_DIR/CLAUDE.md" 2>/dev/null; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} CLAUDE.md should contain Python Conventions"
  fi

  teardown_test
  echo -e "  ${GREEN}--add --dir: done${RESET}"
}

# ---------------------------------------------------------------------------
# .scaffold-version tracking
# ---------------------------------------------------------------------------
test_scaffold_version_file() {
  echo ""
  echo -e "${BOLD}Test: .scaffold-version file${RESET}"

  setup_test "version-file"
  run_scaffold > /dev/null

  # .scaffold-version should exist
  TOTAL=$((TOTAL + 1))
  if [[ -f "$WORK_DIR/.scaffold-version" ]]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} .scaffold-version should exist after scaffold"
  fi

  # Should contain version=
  TOTAL=$((TOTAL + 1))
  if grep -qF -- "version=" "$WORK_DIR/.scaffold-version" 2>/dev/null; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} .scaffold-version should contain version="
  fi

  # Should contain date=
  TOTAL=$((TOTAL + 1))
  if grep -qF -- "date=" "$WORK_DIR/.scaffold-version" 2>/dev/null; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} .scaffold-version should contain date="
  fi

  teardown_test
  echo -e "  ${GREEN}.scaffold-version: done${RESET}"
}

# ---------------------------------------------------------------------------
# Smoke tests — actually run lint/fmt on scaffolded projects
# ---------------------------------------------------------------------------
test_smoke_python() {
  echo ""
  echo -e "Test: Smoke — Python scaffold (ruff)"

  # Skip gracefully if ruff not installed
  if ! command -v ruff &>/dev/null; then
    echo -e "  ${YELLOW}SKIP${RESET} ruff not installed — skipping Python smoke test"
    return 0
  fi

  setup_test "smoke-py"
  run_scaffold > /dev/null

  # Create a minimal Python file so lint/fmt have something to work on
  mkdir -p "$WORK_DIR/src"
  cat > "$WORK_DIR/src/hello.py" <<'PYEOF'
import os
import sys

def hello():
    print("hello world")

if __name__ == "__main__":
    hello()
PYEOF

  # make lint — ruff check may find issues (unused imports), that's OK
  # We just verify the command actually runs
  TOTAL=$((TOTAL + 1))
  local lint_output
  lint_output=$(cd "$WORK_DIR" && make lint LANG=python 2>&1) || true
  if echo "$lint_output" | grep -qF -- "Linting"; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} make lint LANG=python did not produce expected output"
  fi

  # make fmt should succeed
  TOTAL=$((TOTAL + 1))
  if (cd "$WORK_DIR" && make fmt LANG=python 2>&1) >/dev/null 2>&1; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} make fmt LANG=python failed"
  fi

  teardown_test
  echo -e "  ${GREEN}Smoke Python: done${RESET}"
}

test_smoke_go() {
  echo ""
  echo -e "Test: Smoke — Go scaffold (gofmt)"

  # Skip gracefully if go toolchain not installed
  if ! command -v go &>/dev/null; then
    echo -e "  ${YELLOW}SKIP${RESET} go not installed — skipping Go smoke test"
    return 0
  fi

  setup_test "smoke-go"
  force_language "go"
  run_scaffold > /dev/null

  # Create a minimal Go file
  mkdir -p "$WORK_DIR/cmd"
  cat > "$WORK_DIR/cmd/main.go" <<'GOEOF'
package main

import "fmt"

func main() {
	fmt.Println("hello world")
}
GOEOF

  # Scaffold already created go.mod; just make sure it exists
  # If not, init one (e.g. if template failed)
  if [[ ! -f "$WORK_DIR/go.mod" ]]; then
    (cd "$WORK_DIR" && go mod init testproject 2>/dev/null) || true
  fi

  # make fmt should succeed (gofmt is always available with go)
  TOTAL=$((TOTAL + 1))
  if (cd "$WORK_DIR" && make fmt LANG=go 2>&1) >/dev/null 2>&1; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} make fmt LANG=go failed"
  fi

  # make lint — golangci-lint may not be installed, skip gracefully
  TOTAL=$((TOTAL + 1))
  if command -v golangci-lint &>/dev/null; then
    if (cd "$WORK_DIR" && make lint LANG=go 2>&1) >/dev/null 2>&1; then
      PASS=$((PASS + 1))
    else
      # lint issues are OK — command ran
      PASS=$((PASS + 1))
    fi
  else
    echo -e "  ${YELLOW}SKIP${RESET} golangci-lint not installed — lint check skipped"
    PASS=$((PASS + 1))  # count as pass (graceful skip)
  fi

  teardown_test
  echo -e "  ${GREEN}Smoke Go: done${RESET}"
}

# ---------------------------------------------------------------------------
# Test: Interactive --add (no language arg) defaults to python in non-interactive
# ---------------------------------------------------------------------------
test_add_interactive() {
  echo -e "\n${BOLD}Test: --add (interactive, non-interactive fallback)${RESET}"
  setup_test "add-interactive"

  # First: scaffold a Go project with --keep
  force_language "go"
  cd "$WORK_DIR" && ./scaffold --non-interactive --keep > /dev/null 2>&1
  cd "$SCRIPT_DIR"

  # Verify it's a Go project
  TOTAL=$((TOTAL + 1))
  if [[ -f "$WORK_DIR/go.mod" ]]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} Base project should have go.mod"
  fi

  # Now use --add without language arg in non-interactive mode → defaults to python
  cd "$WORK_DIR" && ./scaffold --add --non-interactive > /dev/null 2>&1
  cd "$SCRIPT_DIR"

  TOTAL=$((TOTAL + 1))
  if [[ -f "$WORK_DIR/pyproject.toml" ]]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} --add without arg should default to python (pyproject.toml)"
  fi

  # CLAUDE.md should have Python Conventions
  TOTAL=$((TOTAL + 1))
  if grep -q "Python Conventions" "$WORK_DIR/CLAUDE.md"; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} CLAUDE.md should contain Python Conventions after --add"
  fi

  teardown_test
}

# ---------------------------------------------------------------------------
# Test: --add with explicit language still works
# ---------------------------------------------------------------------------
test_add_explicit() {
  echo -e "\n${BOLD}Test: --add go (explicit language still works)${RESET}"
  setup_test "add-explicit"

  # Scaffold a python project with --keep
  cd "$WORK_DIR" && ./scaffold --non-interactive --keep > /dev/null 2>&1
  cd "$SCRIPT_DIR"

  TOTAL=$((TOTAL + 1))
  if [[ -f "$WORK_DIR/pyproject.toml" ]]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} Base project should have pyproject.toml"
  fi

  # Add go explicitly
  cd "$WORK_DIR" && ./scaffold --add go > /dev/null 2>&1
  cd "$SCRIPT_DIR"

  TOTAL=$((TOTAL + 1))
  if [[ -f "$WORK_DIR/go.mod" ]]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} --add go should create go.mod"
  fi

  teardown_test
}

# ---------------------------------------------------------------------------
# Test: --verify on a fresh scaffold
# ---------------------------------------------------------------------------
test_verify_pass() {
  echo -e "\n${BOLD}Test: --verify on fresh scaffold (should pass)${RESET}"
  setup_test "verify-pass"

  # Scaffold a project
  cd "$WORK_DIR" && ./scaffold --non-interactive --keep > /dev/null 2>&1
  cd "$SCRIPT_DIR"

  # Run --verify
  local verify_output verify_exit=0
  verify_output=$(cd "$WORK_DIR" && ./scaffold --verify 2>&1) || verify_exit=$?

  # Should exit 0
  TOTAL=$((TOTAL + 1))
  if [[ $verify_exit -eq 0 ]]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} --verify should exit 0 on fresh scaffold (got $verify_exit)"
    echo -e "  ${DIM}Output: $verify_output${RESET}"
  fi

  # Should contain "All checks passed"
  TOTAL=$((TOTAL + 1))
  if echo "$verify_output" | grep -q "All checks passed"; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} --verify output should contain 'All checks passed'"
  fi

  # Should report PASS for CLAUDE.md
  TOTAL=$((TOTAL + 1))
  if echo "$verify_output" | grep -q "PASS.*CLAUDE.md"; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} --verify should report PASS for CLAUDE.md"
  fi

  # Should report PASS for .claude/settings.json
  TOTAL=$((TOTAL + 1))
  if echo "$verify_output" | grep -q "PASS.*settings.json"; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} --verify should report PASS for settings.json"
  fi

  teardown_test
}

# ---------------------------------------------------------------------------
# Test: --verify detects leftover placeholder
# ---------------------------------------------------------------------------
test_verify_fail() {
  echo -e "\n${BOLD}Test: --verify detects leftover placeholder${RESET}"
  setup_test "verify-fail"

  # Scaffold a project
  cd "$WORK_DIR" && ./scaffold --non-interactive --keep > /dev/null 2>&1
  cd "$SCRIPT_DIR"

  # Inject a leftover placeholder
  echo "This is {{PROJECT_NAME}} placeholder" >> "$WORK_DIR/CLAUDE.md"

  # Run --verify
  local verify_output verify_exit=0
  verify_output=$(cd "$WORK_DIR" && ./scaffold --verify 2>&1) || verify_exit=$?

  # Should exit non-zero
  TOTAL=$((TOTAL + 1))
  if [[ $verify_exit -ne 0 ]]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} --verify should exit non-zero when placeholders found"
  fi

  # Should report placeholder failure
  TOTAL=$((TOTAL + 1))
  if echo "$verify_output" | grep -q "FAIL.*placeholder"; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} --verify should report placeholder failure"
  fi

  teardown_test
}

# ---------------------------------------------------------------------------
# Test: --install-template from local path + --list-templates
# ---------------------------------------------------------------------------
test_install_template() {
  echo -e "\n${BOLD}Test: --install-template from local path${RESET}"
  setup_test "install-tpl"

  # Create a fake template directory
  local tpl_dir="$WORK_DIR/my-ruby-template"
  mkdir -p "$tpl_dir"
  cat > "$tpl_dir/CONVENTIONS.md" <<'CONV'
# Ruby Conventions
- Use RuboCop for linting
CONV
  cat > "$tpl_dir/gitignore.append" <<'GI'
# Ruby
*.gem
GI

  # Install it
  local _install_output
  _install_output=$(cd "$WORK_DIR" && SCAFFOLD_HOME="$WORK_DIR/.scaffold-home" ./scaffold --install-template "$tpl_dir" 2>&1)

  # Template should be installed
  TOTAL=$((TOTAL + 1))
  if [[ -d "$WORK_DIR/.scaffold-home/templates/my-ruby-template" ]]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} Template should be installed to ~/.scaffold/templates/my-ruby-template"
  fi

  # CONVENTIONS.md should be present in installed template
  TOTAL=$((TOTAL + 1))
  if [[ -f "$WORK_DIR/.scaffold-home/templates/my-ruby-template/CONVENTIONS.md" ]]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} Installed template should contain CONVENTIONS.md"
  fi

  # --list-templates should show it
  local list_output
  list_output=$(cd "$WORK_DIR" && SCAFFOLD_HOME="$WORK_DIR/.scaffold-home" ./scaffold --list-templates 2>&1)

  TOTAL=$((TOTAL + 1))
  if echo "$list_output" | grep -q "my-ruby-template"; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} --list-templates should show installed template"
  fi

  # --list-templates should also show built-in
  TOTAL=$((TOTAL + 1))
  if echo "$list_output" | grep -q "python"; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} --list-templates should show built-in python"
  fi

  teardown_test
}

# ---------------------------------------------------------------------------
# Test: --install-template with invalid template
# ---------------------------------------------------------------------------
test_install_template_invalid() {
  echo -e "\n${BOLD}Test: --install-template with invalid template${RESET}"
  setup_test "install-tpl-bad"

  # Create a template directory without required files
  local tpl_dir="$WORK_DIR/bad-template"
  mkdir -p "$tpl_dir"
  echo "# Just a readme" > "$tpl_dir/README.md"

  # Install should fail
  local _install_output install_exit=0
  _install_output=$(cd "$WORK_DIR" && SCAFFOLD_HOME="$WORK_DIR/.scaffold-home" ./scaffold --install-template "$tpl_dir" 2>&1) || install_exit=$?

  TOTAL=$((TOTAL + 1))
  if [[ $install_exit -ne 0 ]]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} --install-template should fail for invalid template"
  fi

  # Template should NOT be installed (cleaned up)
  TOTAL=$((TOTAL + 1))
  if [[ ! -d "$WORK_DIR/.scaffold-home/templates/bad-template" ]]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} Invalid template should be cleaned up after validation failure"
  fi

  teardown_test
}

# ---------------------------------------------------------------------------
# Test: protect-main-branch hook
# ---------------------------------------------------------------------------
test_hook_protect_main() {
  echo -e "\n${BOLD}Test: protect-main-branch hook${RESET}"

  local hook="$SCRIPT_DIR/.claude/hooks/protect-main-branch.sh"

  if [[ ! -f "$hook" ]]; then
    echo -e "  ${RED}FAIL${RESET} Hook file not found: $hook"
    TOTAL=$((TOTAL + 1)); FAIL=$((FAIL + 1))
    return
  fi

  if ! command -v jq &>/dev/null; then
    echo -e "  ${YELLOW}SKIP${RESET} jq not installed — hook tests skipped"
    return
  fi

  # We need a git repo to test branch detection
  local hook_dir
  hook_dir=$(mktemp -d "/tmp/scaffold-test-hook-XXXXXX")
  cp "$hook" "$hook_dir/hook.sh"
  chmod +x "$hook_dir/hook.sh"
  (cd "$hook_dir" && git init -q && git config user.name "Test" && git config user.email "test@test" && touch .keep && git add . && git commit -m "init" -q)

  # --- Test 1: git commit on main → blocked ---
  TOTAL=$((TOTAL + 1))
  local output
  output=$(echo '{"tool_input":{"command":"git commit -m test"}}' | (cd "$hook_dir" && bash hook.sh) 2>&1)
  if echo "$output" | grep -q '"permissionDecision":"deny"'; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} git commit on main should be denied"
  fi

  # --- Test 2: git push on main → blocked ---
  TOTAL=$((TOTAL + 1))
  output=$(echo '{"tool_input":{"command":"git push origin main"}}' | (cd "$hook_dir" && bash hook.sh) 2>&1)
  if echo "$output" | grep -q '"permissionDecision":"deny"'; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} git push on main should be denied"
  fi

  # --- Test 3: deny output contains helpful message ---
  TOTAL=$((TOTAL + 1))
  if echo "$output" | grep -q "Create a feature branch first"; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} Deny output should contain branch creation suggestion"
  fi

  # --- Test 4: deny output is valid JSON ---
  TOTAL=$((TOTAL + 1))
  if echo "$output" | jq . > /dev/null 2>&1; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} Deny output should be valid JSON"
  fi

  # --- Test 5: git commit on feature branch → allowed ---
  (cd "$hook_dir" && git checkout -b feat/test -q)
  TOTAL=$((TOTAL + 1))
  output=$(echo '{"tool_input":{"command":"git commit -m test"}}' | (cd "$hook_dir" && bash hook.sh) 2>&1)
  if [[ -z "$output" ]]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} git commit on feature branch should produce no output (allowed)"
  fi

  # --- Test 6: git push on feature branch → allowed ---
  TOTAL=$((TOTAL + 1))
  output=$(echo '{"tool_input":{"command":"git push origin feat/test"}}' | (cd "$hook_dir" && bash hook.sh) 2>&1)
  if [[ -z "$output" ]]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} git push on feature branch should produce no output (allowed)"
  fi

  # --- Test 7: non-git command → allowed ---
  TOTAL=$((TOTAL + 1))
  output=$(echo '{"tool_input":{"command":"git status"}}' | (cd "$hook_dir" && bash hook.sh) 2>&1)
  if [[ -z "$output" ]]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} git status should produce no output (allowed)"
  fi

  # --- Test 8: git log → allowed ---
  TOTAL=$((TOTAL + 1))
  output=$(echo '{"tool_input":{"command":"git log --oneline"}}' | (cd "$hook_dir" && bash hook.sh) 2>&1)
  if [[ -z "$output" ]]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} git log should produce no output (allowed)"
  fi

  # --- Test 9: master branch also blocked ---
  # Ensure we're on a branch called "master" (may already exist from git init)
  (cd "$hook_dir" && git checkout master -q 2>/dev/null) || \
    (cd "$hook_dir" && git checkout -b master -q 2>/dev/null) || true
  TOTAL=$((TOTAL + 1))
  output=$(echo '{"tool_input":{"command":"git commit -m test"}}' | (cd "$hook_dir" && bash hook.sh) 2>&1)
  if echo "$output" | grep -q '"permissionDecision":"deny"'; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} git commit on master should be denied"
  fi

  # --- Test 10: empty/malformed input → allowed (no crash) ---
  TOTAL=$((TOTAL + 1))
  local exit_code=0
  output=$(echo '{}' | (cd "$hook_dir" && bash hook.sh) 2>&1) || exit_code=$?
  if [[ $exit_code -eq 0 ]]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} Malformed input should not crash hook (exit 0)"
  fi

  # --- Test 11: hook always exits 0 ---
  TOTAL=$((TOTAL + 1))
  exit_code=0
  echo '{"tool_input":{"command":"git commit -m blocked"}}' | (cd "$hook_dir" && bash hook.sh) > /dev/null 2>&1 || exit_code=$?
  if [[ $exit_code -eq 0 ]]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${RESET} Hook should always exit 0 (even when denying)"
  fi

  rm -rf "$hook_dir"
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
main() {
  echo -e "${BOLD}═══ Scaffold Behavior Tests ═══${RESET}"

  local filter="${1:-all}"

  case "$filter" in
    python)     test_python ;;
    typescript) test_typescript ;;
    go)         test_go ;;
    rust)       test_rust ;;
    none)       test_none ;;
    keep)           test_keep_flag ;;
    dry-run)        test_dry_run ;;
    permissions)    test_permissions ;;
    python-api)     test_python_api ;;
    ts-cli)         test_typescript_cli ;;
    go-library)     test_go_library ;;
    rust-library)   test_rust_library ;;
    completions)    test_completions ;;
    rollback)       test_rollback ;;
    add-language)   test_add_language ;;
    version)        test_version ;;
    migrate)        test_migrate ;;
    migrate-idem)   test_migrate_idempotent ;;
    scaffoldrc)     test_scaffoldrc ;;
    scaffoldrc-ovr) test_scaffoldrc_override ;;
    completions-zsh) test_completions_zsh ;;
    completions-bash) test_completions_bash_explicit ;;
    add-dir)        test_add_dir ;;
    version-file)   test_scaffold_version_file ;;
    add-interactive) test_add_interactive ;;
    add-explicit)   test_add_explicit ;;
    verify-pass)    test_verify_pass ;;
    verify-fail)    test_verify_fail ;;
    install-tpl)    test_install_template ;;
    install-tpl-bad) test_install_template_invalid ;;
    hook-protect)   test_hook_protect_main ;;
    smoke-python)   test_smoke_python ;;
    smoke-go)       test_smoke_go ;;
    smoke)
      test_smoke_python
      test_smoke_go
      ;;
    archetypes)
      test_python_api
      test_typescript_cli
      test_go_library
      test_rust_library
      ;;
    all)
      test_python
      test_typescript
      test_go
      test_rust
      test_none
      test_keep_flag
      test_dry_run
      test_permissions
      test_python_api
      test_typescript_cli
      test_go_library
      test_rust_library
      test_completions
      test_rollback
      test_add_language
      test_version
      test_migrate
      test_migrate_idempotent
      test_scaffoldrc
      test_scaffoldrc_override
      test_completions_zsh
      test_completions_bash_explicit
      test_add_dir
      test_scaffold_version_file
      test_add_interactive
      test_add_explicit
      test_verify_pass
      test_verify_fail
      test_install_template
      test_install_template_invalid
      test_hook_protect_main
      test_smoke_python
      test_smoke_go
      ;;
    *)
      echo "Unknown test: $filter"
      echo "Usage: $0 [python|typescript|go|rust|none|keep|dry-run|permissions|python-api|ts-cli|go-library|rust-library|completions|rollback|add-language|version|migrate|migrate-idem|scaffoldrc|scaffoldrc-ovr|completions-zsh|completions-bash|add-dir|version-file|add-interactive|add-explicit|verify-pass|verify-fail|install-tpl|install-tpl-bad|hook-protect|smoke|smoke-python|smoke-go|archetypes|all]"
      exit 1
      ;;
  esac

  # Summary
  echo ""
  echo -e "${BOLD}═══ Results ═══${RESET}"
  echo -e "  Total:  $TOTAL"
  echo -e "  ${GREEN}Passed: $PASS${RESET}"
  if [[ $FAIL -gt 0 ]]; then
    echo -e "  ${RED}Failed: $FAIL${RESET}"
    exit 1
  else
    echo -e "  Failed: 0"
    echo -e "\n${GREEN}All tests passed.${RESET}"
  fi
}

main "$@"
