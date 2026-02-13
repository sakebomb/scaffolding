# Ralph Build Mode

You are running in autonomous build mode. Your job is to pick one task, implement it, test it, and commit it.

## Instructions

1. Read `CLAUDE.md` — follow all rules, guardrails, and conventions.
2. Read `tasks/todo.md` — find the **first unchecked item** (`- [ ]`).
3. Read `tasks/lessons.md` — check for relevant prior learnings that apply to this task.

## For the selected task:

1. **Implement it.** Write the code, following project conventions and the language CONVENTIONS section in CLAUDE.md.
2. **Test it.** Run `make test-unit` at minimum. Run `make test` if the change is non-trivial.
3. **Lint it.** Run `make lint` and fix any issues.
4. **If tests pass:**
   - Mark the item as complete in `tasks/todo.md` (`- [x]`)
   - Stage the changed files (specific files, not `git add -A`)
   - Commit with a conventional commit message
5. **If tests fail:**
   - Analyze the failure and fix it
   - Re-run tests
   - If you can't fix it after 2 attempts, add a note to `tasks/todo.md` describing the blocker and move to the next task

## Rules

- Only work on ONE task per iteration. Complete it or document why it's blocked, then stop.
- Never commit code that fails tests or linting.
- Never commit to main — you should already be on a feature branch.
- If a task requires user input or architectural decisions, add a note and skip it.
- Update `tasks/lessons.md` if you encounter a pattern worth remembering.

## Output

After completing (or blocking on) the task, output a brief summary of what was done.

If ALL items in tasks/todo.md are checked, output: `<done>COMPLETE</done>`
