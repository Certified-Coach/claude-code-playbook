# Execution Plan

The sanitisation runs as 7 passes, each targeting specific anti-patterns. Passes are sequential — each builds on the previous one's results.

## Before you start

1. All tests passing on your integration branch
2. CI green
3. Create a release branch: `git checkout -b release/sanitisation`
4. Take baseline measurements (the first prompt does this)

## The passes

### Pass 1: Dead Code & Dependencies (AP-1.4, AP-1.5)

**Goal:** Remove everything that isn't used.

**What it does:**
- Finds unused exports, orphan files, commented-out code
- Identifies declared-but-unused dependencies
- Verifies no hallucinated packages (AI sometimes invents package names)
- Creates a GitHub issue for deferred dependency updates

**Key rule:** Don't remove something just because grep can't find a consumer. Check for dynamic imports, framework conventions (e.g., page files consumed by the router), and test infrastructure.

**`/clear` after this pass.** The dead code analysis fills context with file listings.

### Pass 2: Duplication & Consolidation (AP-2.1, AP-2.2, AP-2.3)

**Goal:** Find copy-paste code and extract shared modules.

**What it does:**
- Runs duplication detection (jscpd or equivalent for your language)
- Identifies near-identical files and suggests shared modules
- Proposes consolidation with specific extraction boundaries

**Key rule:** Only consolidate code that is genuinely the same concern. Two files that look similar but serve different domains will diverge — consolidating them creates coupling. Ask: "Will these change for the same reason?"

**CLAUDE.md addition:** "Consolidate infrastructure utilities; do NOT consolidate domain pages that will diverge."

**`/clear` after this pass.**

### Pass 3: Security (AP-4.1 through AP-4.5)

**Goal:** Zero known vulnerabilities, no secrets in code, input validation on all user-facing endpoints.

**What it does:**
- Runs your package manager's audit command and patches CVEs
- Greps for hardcoded secrets, API keys, tokens
- Checks input validation on API routes and server actions
- Reviews CSP headers, cookie security, cryptographic functions

**Key rule:** Security fixes are never deferred. If a CVE exists, patch it now. If a secret is in the code, rotate it now.

**`/clear` after this pass.**

### Pass 4: Architecture (AP-3.1 through AP-3.5)

**Goal:** Validate architectural boundaries, fix violations, document the intended structure.

**What it does:**
- Defines architectural layers (if not already defined)
- Checks every import for layer violations
- Finds business logic in the wrong layer
- Identifies N+1 query patterns
- Flags pattern inconsistencies across features

**Key rule:** Define the layers FIRST, then check violations. You can't find violations without a definition. Add the layer definitions to CLAUDE.md — they're permanent.

**`/clear` after this pass.**

### Pass 5: Bloat (AP-1.1, AP-1.2, AP-1.3)

**Goal:** Reduce file sizes, simplify over-engineered code, remove unnecessary abstractions.

**What it does:**
- Finds files exceeding 300 lines (excluding justified cases like generated code)
- Finds functions exceeding 30 lines
- Identifies single-implementation interfaces and pass-through wrappers
- Checks for custom utilities that duplicate declared dependencies

**Key rule:** The 300-line guideline is a guideline, not a ceiling. A 400-line file with 7 tightly-related components is better than 7 files with 60 lines each. Ask: "Would splitting this make it easier or harder to understand?"

**`/clear` after this pass.**

### Pass 6: Test Health (AP-5.1, AP-5.2, AP-5.3)

**Goal:** Assess test quality, fix quick wins, create a test maturity roadmap.

**What it does:**
- Runs the full test suite, confirms all pass
- Identifies exported functions with zero test coverage
- Finds brittle tests (mock call counts, implementation detail assertions)
- Finds redundant tests (same code path, different names)
- Assesses coverage at each level (unit, integration, E2E)
- Checks skipped tests — valid reason or neglected?

**Key rule:** Don't write all missing tests during sanitisation. Fix quick wins (pure function unit tests), create a GitHub issue for the rest as a test maturity roadmap with effort estimates. Prioritise by risk, not by count.

**`/clear` after this pass.**

### Pass 7: Final Measurement & Release

**Goal:** Prove the value, validate everything passes, create the PR.

**What it does:**
- Takes the same measurements as the baseline
- Produces a delta summary table
- Runs full validation (tests, types, lint, audit, build)
- Removes temporary sanitisation rules from CLAUDE.md
- Pushes and creates a PR with the delta summary

**Key rule:** If validation finds anything broken, fix it before creating the PR. The validation step exists to catch things the passes missed.

## Triage framework

Every finding gets one of three dispositions:

| Disposition | When to use | Action |
|---|---|---|
| **Fix now** | Security issues, bugs, architecture violations, quick wins | Fix in this pass, commit individually |
| **Defer** | Significant effort, low risk, requires design decisions | Create GitHub issue, log in sanitisation report with rationale |
| **Document only** | Intentional deviations, acceptable trade-offs | Add comment in code or note in CLAUDE.md explaining why |

## Context management

**Why `/clear` between passes:** Each pass fills the context window with file listings, grep results, and analysis. Starting fresh for the next pass prevents Claude from hallucinating state from the previous pass's output. The sanitisation log file provides continuity.

**Why individual commits:** Each fix gets its own commit with an AP-ID in the message. This makes the PR reviewable and any single fix revertable without affecting others.

**Why a release branch:** The sanitisation touches many files across the codebase. Isolating it on a branch means if something goes wrong, you can abandon the branch without affecting your integration branch.
