---
name: checkpoint
description: Summarize current progress, commit working state, and update task tracking
argument-hint: "[commit message or empty for auto-generated]"
user-invocable: true
allowed-tools: "Read, Edit, Bash(git status*), Bash(git diff*), Bash(git add *), Bash(git commit *), Bash(git log*)"
---

Create a checkpoint: summarize progress, commit the current working state, and update task tracking.

## Process

1. **Check state** — Run `git status` and `git diff --stat` to see what's changed.
2. **Update tasks/todo.md** — Mark completed items, note any blockers or in-progress work.
3. **Stage changes** — Add modified files (be specific, don't use `git add -A`).
4. **Commit** — Use the provided message or auto-generate one from the changes:
   - Follow conventional commits: `type(scope): description`
   - Types: feat, fix, refactor, chore, docs, test
5. **Report** — Summarize what was committed and what remains.

## Rules

- Never stage `.env` files, credentials, or secrets.
- Never commit files that would fail linting — run `make lint` first if unsure.
- If there are no changes to commit, say so — don't create empty commits.
- If `$ARGUMENTS` is provided, use it as the commit message.
- Always end the commit message with: `Co-Authored-By: Claude <noreply@anthropic.com>`
