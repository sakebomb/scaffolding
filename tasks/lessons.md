# Project Knowledge Base

> This file accumulates across sessions. Review relevant sections at session start.
> Filter by tags to find entries relevant to the current task.

## Tag Reference

| Tag | Domain |
|-----|--------|
| `git` | Version control, branching, merge conflicts |
| `api` | External APIs, integrations, auth |
| `testing` | Test failures, coverage gaps, flaky tests |
| `agent` | Agent behavior, hallucination, prompt issues |
| `pipeline` | Data pipelines, ETL, processing chains |
| `config` | Environment, deployment, secrets, CI/CD |
| `perf` | Performance, optimization, resource usage |
| `security` | Vulnerabilities, credentials, access control |
| `docs` | Documentation gaps, spec ambiguity |
| `infra` | Infrastructure, networking, containers |

> Add new tags as domains emerge. Keep tags short and lowercase.

---

## Mistakes & Corrections

What went wrong and how to prevent it. Updated after any correction loop.

<!--
Pattern: [short description]
Tags: [tag1, tag2]
Mistake: [what went wrong]
Rule: [preventive instruction — make it clear, negative if possible]
Added: [YYYY-MM-DD]
-->

Pattern: Scaffold ran in its own repo, wiping .git history
Tags: git, testing, scaffold
Mistake: The scaffold script was executed inside the scaffolding source repo (via a linter or hook), which ran init_git and created a new .git with a single commit, destroying the real remote-tracking history. All branches and remote config were lost.
Rule: Never run `./scaffold` in the scaffolding source repo itself. If the .git directory has no remote and only 1 commit, suspect this happened. Recovery: re-clone from GitHub, copy .git back, remove scaffolded artifacts (pyproject.toml, src/, .scaffold-version, etc.).
Added: 2026-02-13

Pattern: `|| true` swallows exit code in variable assignment
Tags: bash, testing
Mistake: Used `output=$(command) || true; local exit=$?` — the `|| true` makes `$?` always 0. The exit code of the failed command is lost.
Rule: Use `local exit=0; output=$(command) || exit=$?` pattern to capture both output and exit code.
Added: 2026-02-13

---

## What Works (Positive Patterns)

Patterns, approaches, and techniques that proved effective. Capture what to repeat.

<!--
Pattern: [short description]
Tags: [tag1, tag2]
Context: [when/where this was effective]
Why: [why it works — be specific]
Added: [YYYY-MM-DD]
-->

_No entries yet._

---

## Troubleshooting

Recurring issues with known fixes. Use the symptom-cause-solution format for fast diagnosis.

<!--
Symptom: [what you observe]
Tags: [tag1, tag2]
Cause: [root cause]
Solution: [how to fix it]
Added: [YYYY-MM-DD]
-->

_No entries yet._

---

## Project Insights

Higher-level learnings about the project's architecture, dependencies, or domain. Things a new session needs to know.

<!--
Insight: [what was discovered]
Tags: [tag1, tag2]
Impact: [how this affects decisions or implementation]
Added: [YYYY-MM-DD]
-->

_No entries yet._
