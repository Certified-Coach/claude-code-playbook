# Codebase Sanitisation

A structured, repeatable process for cleaning up a codebase that's accumulated drift. Run it before major releases, after rapid feature development, or when onboarding a team.

## When to run

- **Before a release** — ensure the codebase is clean before users see it
- **After rapid development** — AI-assisted development is fast, which means drift accumulates fast
- **Before onboarding** — new developers (or new Claude sessions) work better with a clean baseline
- **Quarterly** — prevent drift from compounding

## What it covers

7 domains, 27 anti-patterns across 6 passes:

| Pass | Domain | What it finds |
|------|--------|--------------|
| 1 | Dead code & dependencies | Unused exports, orphan files, phantom dependencies |
| 2 | Duplication | Copy-paste code, missing shared modules |
| 3 | Security | CVEs, hardcoded secrets, missing input validation |
| 4 | Architecture | Layer violations, N+1 queries, logic leakage |
| 5 | Bloat | Oversized files, reinvented wheels, over-abstraction |
| 6 | Test health | Coverage gaps, brittle tests, redundant tests |

Pass 7 is final measurement and release.

## How it works

1. **Install skills** — run the skills installer prompt (one-time, adds 6 slash commands)
2. **Create a release branch** — `release/sanitisation` from your integration branch
3. **Run the prompt sequence** — 30 prompts, one at a time, with `/clear` between passes
4. **Review each finding** — every fix is proposed before being applied
5. **Measure the delta** — before/after comparison proves the value

## The skills (available after install)

| Command | What it does |
|---------|-------------|
| `/health-check` | Runs all 6 checks, produces a summary report |
| `/bloat-check` | Finds oversized files, functions, unnecessary abstractions |
| `/dry-check` | Finds duplication, suggests shared modules |
| `/security-check` | CVEs, secrets, input validation, CSP |
| `/arch-check` | Layer violations, N+1 queries, business logic placement |
| `/test-health` | Coverage gaps, brittle tests, redundant tests |

## Day-to-day use

You don't need to run the full sanitisation to use the skills:

- **Before every release:** `/health-check`
- **After adding features:** `/bloat-check` and `/dry-check`
- **Monthly:** `/security-check`
- **After refactoring:** `/arch-check`

## Decision framework

When a finding is identified, decide:

| Stage | Fix now | Defer | Document only |
|-------|---------|-------|--------------|
| Pre-launch | Security, bugs, architecture violations | Test maturity gaps | Intentional deviations |
| Post-launch | Security, data-loss risks | Duplication, bloat | Style inconsistencies |
| Mature product | Everything above threshold | Low-risk items | Acknowledged trade-offs |

## Expected outcomes

From a real sanitisation on a ~60,000 source-line Next.js monorepo:

| Metric | Before | After | Change |
|--------|--------|-------|--------|
| Source code lines | 61,038 | 59,681 | -2.2% |
| Vulnerabilities | 8 | 0 | -100% |
| Duplication | 3.60% | 2.55% | -29% |
| Dependencies | 83 | 76 | -8.4% |
| Tests | 276 | 321 | +16.3% |
| Lint errors | 27 | 0 | -100% |
| Bugs found | 0 | 4 | — |

## Files in this practice

| File | What it is |
|------|-----------|
| `anti-pattern-taxonomy.md` | 27 anti-patterns across 7 domains — the detection catalogue |
| `execution-plan.md` | The 7-pass structure with boundaries and triage rules |
| `prompt-sequence.md` | 30 parameterised prompts to paste into Claude Code |
| `skills-installer.md` | Single prompt that installs all 6 health check skills |
