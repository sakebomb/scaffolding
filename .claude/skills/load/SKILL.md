---
name: load
description: Restore session context from tasks/session.md and orient for resumed work
argument-hint: ""
user-invocable: true
allowed-tools: "Read, Glob, Grep, Bash(git status*), Bash(git branch*), Bash(git log*), Bash(git diff --stat*)"
---

Restore context from a previous session and orient for resumed work.

## Instructions

Read the following files in this order (use Wave-Checkpoint-Wave — read in parallel, then synthesize):

### Wave 1: Read all context files in parallel
1. `tasks/session.md` — what was being worked on, decisions made, next steps
2. `tasks/todo.md` — current plan and progress
3. `tasks/lessons.md` — recent entries (last 3-5 relevant to current task)
4. `tasks/tests.md` — coverage gaps and recent changes
5. `PROJECT_INDEX.md` — project structure and entry points (if it exists)

### Checkpoint: Synthesize and orient
After reading, present a concise session resume to the user:

```
## Session Restored

**Last session**: [date] on branch `[branch]`
**Current focus**: [what was being worked on]
**Progress**: [what was completed]
**Next steps**:
1. [first priority]
2. [second priority]
3. [third priority]

**Open questions from last session**:
- [any unresolved items]

**Active files**: [list of files in play]
```

### Wave 2: Verify current state
1. Run `git status` — check for uncommitted changes
2. Run `git branch` — confirm branch
3. Run `git log --oneline -5` — recent commits

Report any discrepancies between the session state and actual git state (e.g., branch changed, uncommitted work not mentioned in session.md).

## Rules

- If `tasks/session.md` doesn't exist or is empty, say so and offer to run `/index` and `/status` instead.
- If `PROJECT_INDEX.md` doesn't exist, note it and suggest running `/index`.
- Don't start implementing immediately — present the resume and let the user confirm the direction.
- Keep the resume under 20 lines. Reference file paths for details, don't dump contents.
- Check `tasks/lessons.md` for entries tagged with the current task's domain — mention any relevant ones.
