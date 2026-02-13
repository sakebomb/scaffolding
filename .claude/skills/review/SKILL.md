---
name: review
description: Review current code changes for bugs, style issues, and security concerns
argument-hint: "[file path or 'staged' or 'branch']"
user-invocable: true
allowed-tools: "Read, Grep, Glob, Bash(git diff*), Bash(git status*), Bash(git log*)"
context: fork
agent: general-purpose
---

Review the current code changes for bugs, style issues, security concerns, and missed edge cases.

## Scope

- If `$ARGUMENTS` is empty: review all staged changes (`git diff --cached`) and unstaged changes (`git diff`).
- If `$ARGUMENTS` is a file path: review only that file's changes.
- If `$ARGUMENTS` is "branch": review all changes on the current branch vs. main (`git diff main...HEAD`).

## Review Checklist

For each changed file, evaluate:

1. **Correctness** — Does the logic do what it claims? Are there off-by-one errors, null checks, or missing edge cases?
2. **Security** — SQL injection, command injection, XSS, path traversal, hardcoded secrets, OWASP top 10.
3. **Performance** — Unnecessary loops, N+1 queries, missing indexes, large allocations in hot paths.
4. **Style** — Naming conventions, code organization, consistency with existing patterns.
5. **Tests** — Are new code paths covered? Are edge cases tested? Would a regression test catch this bug?

## Output Format

Write findings to `scratch/review_latest.md` with this structure:

```
## Review: <branch or file>

### Critical (must fix)
- [file:line] description

### Warning (should fix)
- [file:line] description

### Nit (optional)
- [file:line] description

### Verdict: APPROVE / NEEDS CHANGES
```

Return a ≤5 line summary to the main context.

## Four Questions Validation

After the review, verify the change against these evidence checks:

1. **Are tests passing?** — Run relevant tests and show output. Never claim "tests pass" without proof.
2. **Are requirements met?** — List each requirement from the task/ticket and confirm it's addressed.
3. **Are assumptions verified?** — Cite docs, source code, or specs for any behavioral claims.
4. **Is there evidence?** — Provide concrete results (test output, build logs, diff excerpts).

Flag any of these red flags in your review:
- Claims without evidence ("should work", "probably fine")
- References to APIs or behaviors that weren't verified against source
- Fabricated identifiers (invented function names, non-existent modules)
- "No side effects" claims without checking callers and shared state
