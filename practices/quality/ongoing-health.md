# Ongoing Code Health

Health checks aren't a one-time event. Without regular checks, the codebase drifts back to the state that prompted the sanitisation.

## Cadence

| Check | When | Why |
|---|---|---|
| `/health-check` | Before every release | Catch drift before users see it |
| `/bloat-check` | After adding 3+ features | Features add code; check if any of it is bloat |
| `/dry-check` | Weekly during active development | Duplication accumulates silently |
| `/security-check` | Monthly, or after adding dependencies | New deps bring new CVEs |
| `/arch-check` | Monthly, or after structural changes | Architecture erodes one import at a time |
| `/test-health` | Before release, or after major refactoring | Ensure tests still cover what matters |

## Embedding in workflow

### Pre-release gate

Add to your release checklist (in CLAUDE.md or your promotion workflow):

Before tagging a release:
1. Run `/health-check`
2. All security findings must be resolved
3. No new architecture violations
4. Test suite fully passing

### PR review

When reviewing PRs, ask:
- Did this PR increase duplication? (quick `/dry-check` on the changed files)
- Did this PR introduce a file over 300 lines?
- Are new functions tested?

### Session discipline

The session-start hook already reminds you to check the release plan. Consider adding:
- "Last `/health-check` was on [date]. If more than 30 days ago, run one."

## When test expectations fail

A critical principle from production use:

**When a test fails, ask whether the CODE is wrong or the TEST is wrong.**

Never blindly adjust test expectations to match current behaviour. The test might be catching a genuine bug. Investigate which is correct, then fix the right one.

## The sanitisation log

Keep your SANITISATION_LOG.md in the repo permanently. It serves as:
- **Baseline record** — what the codebase looked like before sanitisation
- **Decision log** — why certain things were deferred
- **Progress tracker** — measurable improvement over time
- **Onboarding doc** — new developers can see the health trajectory
