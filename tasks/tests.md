# Test Registry

> Living map of test coverage. Update when adding or removing tests.
> Last updated: 2026-02-13

---

## How to Run

| Command | Scope | When to Use |
|---------|-------|-------------|
| `bash tests/test_scaffold.sh` | All scaffold behavior tests (7 suites, 302 assertions) | Before PR, after scaffold changes |
| `bash tests/test_scaffold.sh python` | Single language test | Debugging specific language scaffold |
| `bash tests/test_scaffold.sh keep` | --keep flag test | After changes to cleanup logic |
| `bash tests/test_scaffold.sh permissions` | Permissions test | After changes to permission logic |
| `make test` | Full suite (all tiers) | Before PR, CI validation |
| `make test-unit` | Tier 1 — Unit tests | During development, before commit |
| `make test-integration` | Tier 2 — Integration tests | Before PR |
| `make test-agent` | Tier 3 — Agent behavior tests | When agent specs or behavior logic change |
| `make test-file FILE=path/to/test.py` | Single file | Debugging specific failures |
| `make test-coverage` | Full suite + coverage report | Periodic coverage audits |

---

## Coverage Summary

| Module / Component | Unit | Integration | Agent Behavior | Priority Gap |
|-------------------|------|-------------|----------------|--------------|
| scaffold (init script) | ❌ 0 | ✅ 302 (7 suites) | ❌ 0 | LOW |
| .claude/hooks/protect-main-branch.sh | ❌ 0 | ❌ 0 | ❌ 0 | MEDIUM |
| .claude/skills/ | ❌ 0 | ❌ 0 | ❌ 0 | LOW |

> **Legend**: ✅ = covered (count), ❌ = missing (0), 🟡 = partial
> **Priority Gap**: HIGH = no tests at all, MEDIUM = missing a tier, LOW = adequate coverage

---

## Test Tier Definitions

### Tier 1: Unit Tests
- **Scope**: Individual functions, utilities, parsers, transformers.
- **Speed**: Milliseconds per test.
- **Rules**: No network calls, no file I/O, no database. Mock external dependencies.
- **Location**: `tests/unit/`
- **Naming**: `test_<function>_<scenario>_<expected>`

### Tier 2: Integration Tests
- **Scope**: API endpoints, data pipelines, service interactions, module handoffs.
- **Speed**: Seconds per test (acceptable).
- **Rules**: May use local services (Docker, test DBs). No production endpoints. Use fixtures/factories.
- **Location**: `tests/integration/`
- **Naming**: `test_integration_<component>_<scenario>`

### Tier 3: Agent Behavior Tests
- **Scope**: End-to-end agent output validation, anti-hallucination checks, schema compliance.
- **Speed**: Seconds to minutes (LLM calls may be involved).
- **Rules**: Validate outputs against expected patterns/schemas. Check for hallucination indicators.
- **Location**: `tests/agent/`
- **Naming**: `test_agent_<agent_name>_<behavior>`

**Anti-hallucination checks to include**:
- No fabricated identifiers (CVE IDs, IP addresses, domains, tool names)
- Confidence scores present where required
- Sources/references are verifiable or flagged as unverified
- Graceful handling of ambiguous or insufficient input
- Output matches expected schema/format

---

## Coverage Gaps & TODO

- [x] Scaffold behavior tests for all 4 languages + none + --keep + permissions
- [ ] Hook tests (protect-main-branch.sh) — mock git branch, verify JSON output
- [ ] Makefile target tests — verify each language's targets resolve correctly

---

## Flaky Test Tracker

> Tests that intermittently fail must be fixed or quarantined immediately. Never normalize "expected failures."

| Test | First Seen | Status | Notes |
|------|-----------|--------|-------|
| _none_ | — | — | — |
