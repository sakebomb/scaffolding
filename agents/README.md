# /agents

Agent specifications for Claude Code subagents. Each agent has a focused purpose, defined inputs/outputs, and a context budget to prevent window bloat.

## Agent Roster

### Core Agents (workflow essentials)

| Agent | File | Purpose | Context Budget | Slash Command |
|-------|------|---------|---------------|---------------|
| **Plan** | `plan-agent.md` | Break down tasks into checkpointed implementation plans | 30% | `/plan` |
| **Research** | `research-agent.md` | Deep-dive investigation, library evaluation, context gathering | 40% | — |
| **Code Review** | `code-review-agent.md` | Pre-commit diff review for bugs, style, and security | 20% | `/review` |
| **Test Runner** | `test-runner-agent.md` | Run tests, analyze failures, propose fixes | 25% | `/test` |

### Extended Agents (specialized capabilities)

| Agent | File | Purpose | Context Budget | Slash Command |
|-------|------|---------|---------------|---------------|
| **Build Validator** | `build-validator-agent.md` | Compile, type-check, lint — "does it build?" | 15% | — |
| **Code Architect** | `code-architect-agent.md` | System design, architecture decisions, tradeoff analysis | 35% | — |
| **Code Simplifier** | `code-simplifier-agent.md` | Find unnecessary complexity, suggest simplifications | 25% | `/simplify` |
| **Verify** | `verify-agent.md` | Full pre-merge pipeline (build + test + review) | 30% | — |

## When to Use Which Agent

```
Task received
├── Complex? (5+ steps, unclear scope)
│   └── Plan Agent → structured plan in tasks/todo.md
│
├── Need context? (unfamiliar code, new library, API docs)
│   └── Research Agent → findings in scratch/research_*.md
│
├── Architecture question? (system design, technology choice)
│   └── Code Architect → analysis in scratch/architecture_*.md
│
├── Code written → pre-commit checks:
│   ├── Build Validator → compile + type-check + lint
│   ├── Test Runner → unit → integration → agent tests
│   └── Code Review → diff review for bugs & security
│
├── Something feel over-engineered?
│   └── Code Simplifier → complexity report in scratch/simplify_*.md
│
└── Ready to merge?
    └── Verify Agent → full pipeline (build + test + review + summary)
```

## Orchestration Rules

1. **Parallelize when independent**: Research + Code Review can run simultaneously. Build Validator must finish before Test Runner starts.
2. **Context budget enforcement**: If a subtask would consume >20% of remaining context, delegate to a subagent.
3. **Output hygiene**: Agents write detailed output to `scratch/`. Only summaries (≤10 lines) return to the main context.
4. **Don't chain unnecessarily**: If a task only needs one agent, use one agent. Don't run the full pipeline for a typo fix.

## Spec Convention

Each agent spec follows this structure:

```markdown
# Agent: <Name>

## Purpose
What this agent does and when to use it.

## When to Use
Trigger conditions and scenarios.

## Inputs
What information it needs to operate.

## Outputs
What it produces, where it writes, and what it returns to main context.

## Context Budget
Maximum percentage of context window it should consume.

## Rules
Constraints, behavioral guidelines, and edge cases.
```

## Adding New Agents

1. Create `agents/<name>-agent.md` following the convention above.
2. Add the agent to the roster table in this README.
3. Update the "When to Use" decision tree if applicable.
4. If the agent has a slash command, create a corresponding skill in `.claude/skills/`.
5. Update CLAUDE.md Section 4.2 with a summary reference.
