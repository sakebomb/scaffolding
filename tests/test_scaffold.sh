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
  GREEN='\033[0;32m' RED='\033[0;31m' BOLD='\033[1m' DIM='\033[2m' RESET='\033[0m'
else
  GREEN='' RED='' BOLD='' DIM='' RESET=''
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

# ---------------------------------------------------------------------------
# Test: Common structure (shared by all languages)
# ---------------------------------------------------------------------------
assert_common_structure() {
  # Core files
  assert_file_exists "CLAUDE.md"
  assert_file_exists "README.md"
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
  assert_file_exists ".claude/hooks/protect-main-branch.sh"

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
    keep)       test_keep_flag ;;
    permissions) test_permissions ;;
    all)
      test_python
      test_typescript
      test_go
      test_rust
      test_none
      test_keep_flag
      test_permissions
      ;;
    *)
      echo "Unknown test: $filter"
      echo "Usage: $0 [python|typescript|go|rust|none|keep|permissions|all]"
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
