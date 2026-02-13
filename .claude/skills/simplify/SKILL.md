---
name: simplify
description: Analyze code for unnecessary complexity and suggest simplifications
argument-hint: "<file path or directory>"
user-invocable: true
allowed-tools: "Read, Grep, Glob"
context: fork
agent: general-purpose
---

Analyze the specified code for unnecessary complexity and suggest simplifications.

## Scope

- If `$ARGUMENTS` is a file: analyze that specific file.
- If `$ARGUMENTS` is a directory: scan for the most complex files and prioritize.
- If `$ARGUMENTS` is empty: analyze recently changed files (`git diff --name-only main...HEAD`).

## What to Look For

1. **Premature abstractions** — Wrappers, helpers, or utilities used only once. Three similar lines are better than a premature abstraction.
2. **Over-engineering** — Feature flags, backwards-compatibility shims, or configurability that isn't needed yet.
3. **Dead code** — Unused imports, unreachable branches, commented-out blocks.
4. **Unnecessary indirection** — Layers that just pass through, factories that build one thing, interfaces with one implementation.
5. **Complex conditionals** — Deeply nested if/else, long boolean chains that could be simplified.
6. **Duplicated logic** — Copy-paste code that should be a function (only if used 3+ times).

## Output Format

Write findings to `scratch/simplify_latest.md`:

```
## Simplification Report: <scope>

### High Impact
- [file:line] What to simplify and why. Estimated reduction: X lines.

### Medium Impact
- [file:line] Description.

### Low Impact / Nitpicks
- [file:line] Description.

### Summary
- Total opportunities: N
- Estimated net line reduction: X
- Recommendation: [act now / defer / skip]
```

Return a ≤5 line summary to the main context.

## Rules

- Don't suggest changes that would break existing tests.
- Don't remove code that handles real edge cases — only remove genuinely dead paths.
- Simplicity > cleverness. The goal is clarity, not fewer characters.
- Present options — don't apply changes without approval.
