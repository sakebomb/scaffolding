---
name: save
description: Snapshot current session state to tasks/session.md for cross-session continuity
argument-hint: "[optional note about current focus]"
user-invocable: true
allowed-tools: "Read, Write, Edit, Bash(git status*), Bash(git branch*), Bash(git diff --stat*), Bash(git log*)"
---

Save the current session state to `tasks/session.md` so a future session can resume with full context.

## Philosophy

**Compress often, persist the essentials, look up details on demand.**

The session file captures *what you need to know* to resume — not a full transcript. Pair it with:
- `tasks/todo.md` — what the plan is
- `tasks/lessons.md` — what was learned
- `tasks/tests.md` — what's tested
- `PROJECT_INDEX.md` — what exists in the codebase

Together these form the "always available" context layer. The actual code is the "look up when needed" layer.

## When to Save

- Before ending a session
- At natural checkpoints (feature complete, before a risky change)
- When context window is getting large (~60% capacity)
- Before switching to a different task
- If `$ARGUMENTS` is provided, use it as the "Current Focus" description

## What to Capture

Update `tasks/session.md` with:

### 1. Current Focus
What task or feature is actively being worked on. One sentence.

### 2. Progress
What has been completed in the current work stream. Bullet list of concrete accomplishments. Reference specific files or commits where relevant.

### 3. Key Decisions
Architectural or implementation decisions made during this session. Future sessions need these to avoid re-debating settled questions.

### 4. Open Questions
Unresolved questions or uncertainties. Be specific — "does the API support batch operations?" not "some things are unclear."

### 5. Active Files
Files currently being modified or that are critical context. This tells the next session where to start reading.

### 6. Next Steps
Concrete actions to take when resuming. Ordered by priority.

### 7. Session Metadata
- Last saved: today's date + time
- Branch: current git branch
- Context health: estimate how much of the context window is used (light/moderate/heavy)

## Rules

- Overwrite the previous session state — this is a snapshot, not a log.
- Keep it concise. Each section should be 1-5 bullet points max.
- Reference file paths, not file contents.
- If `tasks/todo.md` is up to date, don't duplicate progress here — just note what's changed since the last todo update.
- Always run `git status` and `git branch` to capture accurate git state.
- Mark items in `tasks/todo.md` as complete if they were finished during this session.
