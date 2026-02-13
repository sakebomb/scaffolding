#!/usr/bin/env bash
# =============================================================================
# Ralph Wiggum Loop — Autonomous AI Coding for Claude Code
# =============================================================================
# Runs Claude Code in iterative cycles: plan → build → verify → repeat.
# Each iteration gets a fresh context window. Progress persists via tasks/todo.md.
#
# Usage:
#   ./scripts/ralph-loop.sh              # Run build loop (default)
#   ./scripts/ralph-loop.sh plan         # Run planning mode
#   ./scripts/ralph-loop.sh build        # Run build mode (explicit)
#   ./scripts/ralph-loop.sh --max 10     # Limit to 10 iterations
#
# State files (shared between iterations):
#   tasks/todo.md      — Implementation plan (the "shared memory")
#   tasks/lessons.md   — Accumulated lessons
#   CLAUDE.md          — Agent constitution
#
# Stop conditions:
#   - All items in tasks/todo.md are checked off
#   - Claude outputs <done>COMPLETE</done>
#   - Max iterations reached (default: 20)
#   - Manual interrupt (Ctrl+C)
# =============================================================================
set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
MODE="${1:-build}"
MAX_ITERATIONS=20
ITERATION=0
COOLDOWN_SECONDS=5
LOG_DIR="scratch/ralph-logs"
PROMPT_DIR="."

# Parse flags
shift 2>/dev/null || true
while [[ $# -gt 0 ]]; do
  case "$1" in
    --max)
      MAX_ITERATIONS="$2"
      shift 2
      ;;
    --cooldown)
      COOLDOWN_SECONDS="$2"
      shift 2
      ;;
    *)
      echo "Unknown flag: $1"
      exit 1
      ;;
  esac
done

# ---------------------------------------------------------------------------
# Setup
# ---------------------------------------------------------------------------
mkdir -p "$LOG_DIR"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$LOG_DIR/ralph_${MODE}_${TIMESTAMP}.log"

echo "═══ Ralph Wiggum Loop ═══"
echo "Mode: $MODE"
echo "Max iterations: $MAX_ITERATIONS"
echo "Log: $LOG_FILE"
echo "========================="

# ---------------------------------------------------------------------------
# Prompt selection
# ---------------------------------------------------------------------------
if [[ "$MODE" == "plan" ]]; then
  PROMPT_FILE="$PROMPT_DIR/PROMPT_plan.md"
elif [[ "$MODE" == "build" ]]; then
  PROMPT_FILE="$PROMPT_DIR/PROMPT_build.md"
else
  echo "Unknown mode: $MODE (use 'plan' or 'build')"
  exit 1
fi

if [[ ! -f "$PROMPT_FILE" ]]; then
  echo "Prompt file not found: $PROMPT_FILE"
  exit 1
fi

# ---------------------------------------------------------------------------
# Main loop
# ---------------------------------------------------------------------------
while [[ $ITERATION -lt $MAX_ITERATIONS ]]; do
  ITERATION=$((ITERATION + 1))
  ITER_LOG="$LOG_DIR/iteration_${ITERATION}.log"

  echo ""
  echo "--- Iteration $ITERATION / $MAX_ITERATIONS ---"
  echo "$(date '+%Y-%m-%d %H:%M:%S') Starting iteration $ITERATION" >> "$LOG_FILE"

  # Run Claude Code with the prompt file
  # --print flag runs non-interactively and outputs the response
  RESULT=$(claude --print --prompt-file "$PROMPT_FILE" 2>&1) || true

  # Log the output
  echo "$RESULT" > "$ITER_LOG"
  echo "$(date '+%Y-%m-%d %H:%M:%S') Iteration $ITERATION complete" >> "$LOG_FILE"

  # Check for completion signal
  if echo "$RESULT" | grep -q '<done>COMPLETE</done>'; then
    echo ""
    echo "✅ Ralph detected completion signal. All tasks done!"
    echo "$(date '+%Y-%m-%d %H:%M:%S') COMPLETE after $ITERATION iterations" >> "$LOG_FILE"
    exit 0
  fi

  # Check if all todo items are checked
  if [[ -f "tasks/todo.md" ]]; then
    UNCHECKED=$(grep -c '^\- \[ \]' tasks/todo.md 2>/dev/null || echo "0")
    if [[ "$UNCHECKED" == "0" ]]; then
      echo ""
      echo "✅ All items in tasks/todo.md are complete!"
      echo "$(date '+%Y-%m-%d %H:%M:%S') All todo items checked after $ITERATION iterations" >> "$LOG_FILE"
      exit 0
    fi
    echo "Remaining tasks: $UNCHECKED"
  fi

  # Cooldown between iterations
  if [[ $ITERATION -lt $MAX_ITERATIONS ]]; then
    echo "Cooling down ${COOLDOWN_SECONDS}s before next iteration..."
    sleep "$COOLDOWN_SECONDS"
  fi
done

echo ""
echo "⚠️  Max iterations ($MAX_ITERATIONS) reached. Review tasks/todo.md for remaining work."
echo "$(date '+%Y-%m-%d %H:%M:%S') MAX_ITERATIONS reached" >> "$LOG_FILE"
exit 1
