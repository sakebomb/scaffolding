---
name: lesson
description: Record a lesson learned in tasks/lessons.md — mistakes, positive patterns, troubleshooting, or insights
argument-hint: "<what happened and the takeaway>"
user-invocable: true
allowed-tools: "Read, Edit"
---

Add a new entry to the appropriate section of `tasks/lessons.md`.

## Instructions

1. Read the current `tasks/lessons.md` to understand the existing format and entries.
2. Determine which section the entry belongs in:

   **Mistakes & Corrections** — Something went wrong, capture the preventive rule:
   ```
   Pattern: [short description]
   Tags: [tag1, tag2]
   Mistake: [what went wrong]
   Rule: [preventive instruction — negative, clear]
   Added: [YYYY-MM-DD]
   ```

   **What Works (Positive Patterns)** — Something worked well, capture what to repeat:
   ```
   Pattern: [short description]
   Tags: [tag1, tag2]
   Context: [when/where this was effective]
   Why: [why it works]
   Added: [YYYY-MM-DD]
   ```

   **Troubleshooting** — A recurring issue with a known fix:
   ```
   Symptom: [what you observe]
   Tags: [tag1, tag2]
   Cause: [root cause]
   Solution: [how to fix it]
   Added: [YYYY-MM-DD]
   ```

   **Project Insights** — A discovery about the project's architecture or domain:
   ```
   Insight: [what was discovered]
   Tags: [tag1, tag2]
   Impact: [how this affects decisions]
   Added: [YYYY-MM-DD]
   ```

3. If `$ARGUMENTS` is provided, use it as context for the entry.
4. If `$ARGUMENTS` is empty, ask what happened and determine the right category.

## Rules

- Write rules that ruthlessly prevent recurrence (for mistakes).
- Be specific enough that a future session can understand and apply the entry without additional context.
- Tags should be short, lowercase, and match the tag reference table.
- Don't duplicate — check if a similar entry already exists before adding.
- Positive patterns are just as valuable as mistakes. Capture what works.
