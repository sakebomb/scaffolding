---
name: backlog
description: Manage GitHub issues backlog — view, pick, or create work items
argument-hint: "[show|new|pick #N|close #N]"
user-invocable: true
allowed-tools: "Read, Write, Edit, Bash(gh *), Bash(git checkout*), Bash(git branch*), Bash(git status*)"
---

Manage the GitHub issues backlog. Bridge between GitHub Issues and local task management.

## Commands

Parse `$ARGUMENTS` to determine the action:

### `show` (default — when no argument or `show`)

1. Run `gh issue list --state open --limit 20` to get open issues.
2. Group by priority label (`P0-critical`, `P1-high`, `P2-medium`, `P3-low`, unlabeled).
3. Present a summary:

```
## Open Issues

### P0 — Critical
- #12 Fix auth token expiration (bug, in-progress)

### P1 — High
- #8 Add rate limiting to API (feature, ready)
- #11 Database migration fails on empty tables (bug, ready)

### P2 — Medium
- #3 Refactor config loader (refactor, needs-triage)

### Unprioritized
- #14 Update README examples (task)

**Total**: 5 open issues
```

### `new`

Create a new GitHub issue interactively:

1. Ask the user for:
   - **Title** (required)
   - **Type** — bug, feature, task, chore, or refactor (maps to label)
   - **Priority** — P0-P3 (maps to label)
   - **Description** (required)
   - **Acceptance criteria** (optional)
2. Create with `gh issue create --title "..." --body "..." --label "type,priority,needs-triage"`
3. Report the issue URL.

### `pick #N`

Start working on issue #N:

1. Run `gh issue view N` to get the issue details.
2. Create a branch: `git checkout -b <type>/<N>-<short-title>` (derive type from label, slugify the title).
3. Add `in-progress` label, remove `ready` label: `gh issue edit N --add-label "in-progress" --remove-label "ready"`
4. Write the issue description and acceptance criteria into `tasks/todo.md` as a plan.
5. Present the plan and ask the user to confirm before starting implementation.

### `close #N`

Close issue #N:

1. Run `gh issue view N` to get context.
2. Ask the user for a brief summary of what was done.
3. Add a closing comment with the summary: `gh issue comment N --body "..."`
4. Close the issue: `gh issue close N --reason completed`
5. Remove `in-progress` label if present.

## Rules

- Always show issue numbers so the user can reference them.
- If `gh` is not available or not authenticated, say so and suggest `gh auth login`.
- For `pick`, always verify there are no uncommitted changes before creating a branch.
- For `pick`, use the branch naming convention: `<type>/<issue-number>-<short-slug>` (e.g., `feat/8-rate-limiting`, `fix/12-auth-token`).
- Keep `tasks/todo.md` as the working plan — issues are the backlog, todo.md is the active session plan.
