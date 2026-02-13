# Ralph Planning Mode

You are running in autonomous planning mode. Your job is to analyze the project and create or update the implementation plan.

## Instructions

1. Read `CLAUDE.md` to understand the project constitution and conventions.
2. Read `tasks/todo.md` to see the current plan state.
3. Read `tasks/lessons.md` for any prior learnings.
4. Scan the codebase to understand the current state of implementation.

## If no plan exists (todo.md is a template or empty):
- Analyze the project requirements from README.md, any spec files, or issue tracker.
- Create a structured plan in `tasks/todo.md` following the template format:
  - Objective (one sentence)
  - Numbered steps with checkboxes
  - Checkpoints for tasks >5 steps
  - Decisions & context section
- Estimate complexity per step (trivial / moderate / complex).
- Identify risks and dependencies.

## If a plan already exists:
- Review progress: which items are checked, which remain.
- Assess whether the plan needs updating based on:
  - New information discovered during implementation
  - Steps that turned out harder/easier than expected
  - Blockers or dependencies that changed
- Update the plan if needed. Add new steps, re-order, or mark items as blocked.

## Output

After updating the plan, output a brief summary of what was planned/updated.

If the plan is complete (all items checked), output: `<done>COMPLETE</done>`
