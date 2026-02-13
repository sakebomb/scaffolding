#!/usr/bin/env bash
# Hook: Prevent git commit and git push on main/master branches.
# Enforces the "never commit to main directly" guardrail from CLAUDE.md Section 2.2.
#
# Exit codes:
#   0 — allow the command
#   2 — block the command (stderr fed to Claude as feedback)
#
# Output: JSON with permissionDecision when blocking.
set -euo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Only check git commit and git push commands
if [[ "$COMMAND" == *"git commit"* ]] || [[ "$COMMAND" == *"git push"* ]]; then
  CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")

  if [[ "$CURRENT_BRANCH" == "main" ]] || [[ "$CURRENT_BRANCH" == "master" ]]; then
    echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"Direct commits and pushes to the '"$CURRENT_BRANCH"' branch are blocked by project policy (CLAUDE.md Section 2.2). Create a feature branch first: git checkout -b feat/your-description"}}'
    exit 0
  fi
fi

# Allow everything else
exit 0
