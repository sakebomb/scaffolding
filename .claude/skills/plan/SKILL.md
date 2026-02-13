---
name: plan
description: Create a structured implementation plan in tasks/todo.md with confidence assessment
argument-hint: "<task description>"
user-invocable: true
allowed-tools: "Read, Write, Edit, Glob, Grep"
---

Create a structured implementation plan for the following task: $ARGUMENTS

## Instructions

1. **Explore first** — Read relevant files and understand the current codebase state before planning.
2. **Assess confidence** — Before writing the plan, run a confidence check (see below).
3. **Write the plan** to `tasks/todo.md` using this structure:
   - Objective (one sentence)
   - Confidence score and assessment summary
   - Numbered steps with checkboxes (`- [ ]`)
   - Checkpoints for tasks >5 steps (explicit user check-in points)
   - Decisions & context section for architectural tradeoffs
4. **Assess complexity** — Note estimated effort per step (trivial/moderate/complex).
5. **Identify risks** — What could go wrong? What depends on external factors?
6. **Present a summary** inline — don't make the user read the whole file.

## Confidence Check

Before planning, score your confidence (0.0 - 1.0) across these five dimensions:

| Check | Weight | Question |
|-------|--------|----------|
| **No duplicates** | 25% | Has this already been built? Search the codebase for existing implementations. |
| **Architecture fit** | 25% | Does this align with the project's existing patterns and structure? |
| **Requirements clear** | 20% | Are the requirements specific enough to implement without guessing? |
| **Approach verified** | 15% | Is the technical approach backed by documentation or working references? |
| **Root cause known** | 15% | (For bug fixes) Is the root cause identified, not just symptoms? |

**Thresholds**:
- **>= 0.9** — Proceed with planning and implementation.
- **0.7 - 0.89** — Plan, but flag uncertainties. Present alternative approaches. Get explicit approval before implementing.
- **< 0.7** — Stop. List what's unclear. Ask targeted questions before planning further.

Include the confidence score and a one-line assessment in the plan header:
```
> Confidence: 0.85 — Architecture fit clear, but API behavior needs verification.
```

## Milestone Prompt

After writing the plan, if the plan has 2+ checkpoints, ask the user:

> "This plan has [N] checkpoints. Would you like to create GitHub milestones for them?"

If yes:
1. Create milestones via `gh api repos/{owner}/{repo}/milestones` for each checkpoint.
2. If issues exist for the work items, assign them to the appropriate milestone.
3. Note the milestone names in `tasks/todo.md` next to each checkpoint.

If `gh` is not available or the user declines, skip silently.

## Rules

- Tasks under 3 steps: skip the plan, just execute. Still run the confidence check mentally.
- Tasks with 3+ steps: write the plan, present summary, wait for approval.
- Reference `tasks/lessons.md` for relevant prior learnings.
- Never start implementing before the plan is approved.
- If confidence is below 0.7, do NOT write a full plan — write questions instead.
