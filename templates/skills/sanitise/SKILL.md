---
name: sanitise
description: Full 7-pass codebase sanitisation — dead code, duplication, security, architecture, bloat, test health, and final validation. 30 steps with review gates.
user_invocable: true
---

# /sanitise — Full codebase sanitisation

Run all 7 passes of the sanitisation sequence. Each pass analyses, presents findings for review, applies approved fixes, and commits. Use subagents for each pass to manage context (equivalent of `/clear` between passes).

**Prerequisites:** All tests passing, CI green, on integration branch.

---

## Pass 0: Setup

### Step 1 — Confirm readiness

Check that the codebase is in a clean state:

```bash
git status
```

If there are uncommitted changes, STOP and ask the user to commit or stash first.

Read CLAUDE.md to identify: package manager, source directory, test/build/lint/audit commands, integration branch. If any are missing, ask the user.

### Step 2 — Create branch and baseline

```bash
git checkout -b release/sanitisation
```

Take baseline measurements and record in `SANITISATION_LOG.md`:
1. Lines of code by extension
2. Total file count
3. Dependency counts: production and dev
4. Top 20 largest source files by line count
5. Total exports (grep for export patterns)
6. Code duplication percentage (use jscpd or language equivalent if available, or estimate via grep)
7. Run audit command — record vulnerability count by severity
8. Run test command — record total, passing, failing, skipped

Commit: `DOCS: create sanitisation log with baseline measurements`

### Step 3 — Add temporary rules

Add a `## SANITISATION MODE (TEMPORARY)` section to CLAUDE.md:
- Currently on `release/sanitisation` branch
- Every fix gets its own commit with AP-ID in the message (e.g., `FIX(AP-1.4): remove unused UserCard export`)
- Run tests after every change
- Do NOT auto-fix findings — present them for review first
- Record all findings and decisions in SANITISATION_LOG.md
- Deferred items get a GitHub issue

Commit: `DOCS: add temporary sanitisation rules to CLAUDE.md`

---

## Pass 1: Dead Code & Dependencies

**Launch a subagent** for this pass. Provide it with: source directory, package manager, test command, build command.

### Step 4 — Find dead exports

Find all unused exports in the source directory. For each export:
- grep for the export name across the codebase
- Check for dynamic imports and framework conventions (page files, layout files, middleware, etc.)
- Check test files (test-only consumers = test infrastructure, not dead code)

List every export with zero consumers. State file, line number, and confidence level.

**REVIEW GATE: Present findings to user. Wait for approval before proceeding.**

### Step 5 — Find dead files and commented-out code

Find:
1. Files with zero imports (orphan files). Exclude framework entry points.
2. Commented-out code blocks longer than 3 lines. Exclude license headers.
3. Unreachable code after return/throw statements.

State file, line number, and recommendation (delete or keep with rationale).

**REVIEW GATE: Present findings to user. Wait for approval.**

### Step 6 — Audit dependencies

Run the audit command. Report all vulnerabilities by severity.

Check for unused dependencies:
1. For each production dependency, grep source for imports from that package
2. Flag any with zero imports as removal candidates
3. Check if apparently-unused deps are peer dependencies or framework requirements
4. Verify every declared dependency actually exists in the package registry (hallucination check)

**REVIEW GATE: Present findings to user. Wait for approval.**

### Step 7 — Apply Pass 1 fixes

Apply the approved fixes from Steps 4-6:
1. Remove confirmed dead exports
2. Remove confirmed orphan files
3. Remove confirmed commented-out code blocks
4. Remove confirmed unused dependencies

Commit each category separately with AP-ID format. Run tests and build after all changes.
Record Pass 1 results in SANITISATION_LOG.md.

### Step 8 — Create deferred issues

For dependency updates too risky to apply now (major bumps, breaking changes), create a GitHub issue: `chore: post-sanitisation dependency updates` with the full list.

**End of Pass 1. Context will be cleared for Pass 2.**

---

## Pass 2: Duplication & Consolidation

**Launch a new subagent** for this pass.

### Step 9 — Measure duplication

Run duplication detection on source directory. Use jscpd (JS/TS), or language-appropriate tool. Min 5 lines, 50 tokens.

Report: total duplication percentage, clone pair count, total duplicated lines.
List all clone pairs sorted by size (largest first).

### Step 10 — Analyse clone pairs

Classify each clone pair:
- **Tier 1 — Extract now:** Identical code, same purpose. Safe to consolidate.
- **Tier 2 — Extract later:** Similar but may diverge. Flag, don't consolidate.
- **Tier 3 — Acceptable:** Intentional duplication (different domains that will evolve independently).

For Tier 1: propose specific shared module with file path and extraction boundaries.

**REVIEW GATE: Present classification to user. Wait for approval.**

### Step 11 — Apply Pass 2 fixes

Apply approved Tier 1 extractions:
1. Create the shared file
2. Update all consumers to import from shared file
3. Run tests after each extraction
4. Commit each extraction separately

Record Pass 2 results in SANITISATION_LOG.md including before/after duplication percentage.

### Step 12 — Track deferred duplication

Create a GitHub issue for Tier 2 items: `chore: deferred duplication consolidation`

**End of Pass 2.**

---

## Pass 3: Security

**Launch a new subagent** for this pass.

### Step 13 — Fix CVEs

Run audit command. For each vulnerability:
1. Check if a patched version exists
2. Check if the patch introduces breaking changes
3. Apply the patch (version bump or override)
4. Run tests after each patch

Commit each fix separately with CVE ID in the message.

**Note:** Security fixes are never deferred. If a CVE exists, patch it now.

### Step 14 — Check for secrets and crypto

Search source for:
1. Hardcoded strings that look like API keys, tokens, passwords, connection strings
2. Weak random number generation for security purposes
3. Missing or weak CSRF protection
4. Permissive CSP headers or missing security headers

**REVIEW GATE: Present findings. Wait for approval.**

### Step 15 — Check input validation

For every API route and server action:
1. Is user input validated before use?
2. Are there length limits on string inputs?
3. Are there format checks on IDs, emails, URLs?
4. Is output properly escaped to prevent XSS?

**REVIEW GATE: Present findings. Wait for approval.**

### Step 16 — Apply Pass 3 fixes

Apply approved security fixes from Steps 14-15. Commit each fix separately.
Run tests and build. Record Pass 3 results in SANITISATION_LOG.md.

**End of Pass 3.**

---

## Pass 4: Architecture

**Launch a new subagent** for this pass.

### Step 17 — Define and check layers

Read CLAUDE.md for existing architectural layer definitions. If none exist, analyse the codebase and propose layers with import direction rules.

Then check every import for:
1. Layer violations (imports crossing boundaries in wrong direction)
2. Database/ORM calls outside the data access layer
3. Business logic in API routes or UI components
4. N+1 query patterns (DB queries inside loops)
5. Pattern inconsistencies (same task done differently across features)

**REVIEW GATE: Present findings and proposed layers. Wait for approval.**

### Step 18 — Apply Pass 4 fixes

Apply approved architecture fixes:
1. Fix each violation
2. Run tests after each
3. Commit with AP-ID format

Add the architectural layer definitions to CLAUDE.md as a permanent section.
Record Pass 4 results in SANITISATION_LOG.md.

### Step 19 — Document architecture

Add to CLAUDE.md:
- Layer definitions and import direction rules
- Data access patterns
- Any intentional deviations with rationale

Commit documentation separately.

**End of Pass 4.**

---

## Pass 5: Bloat

**Launch a new subagent** for this pass.

### Step 20 — Analyse bloat

Find:
1. All files exceeding 300 lines — assess whether each can be split by responsibility
2. All functions exceeding 30 lines — identify extractable sub-functions
3. Custom utility implementations that duplicate declared dependencies
4. Interfaces/abstract classes with exactly one implementation
5. Pass-through wrapper functions that add no logic
6. Unnecessary intermediate variables (assigned once, used once on next line)

Check whether largest files are dead code before proposing refactoring.

**REVIEW GATE: Present findings with specific recommended actions. Wait for approval.**

### Step 21 — Apply Pass 5 fixes

Apply approved bloat fixes. For structural extractions (file splits):
1. Show proposed split before committing
2. Create new files
3. Update all imports
4. Run tests and build
5. Commit each extraction separately

Record Pass 5 results in SANITISATION_LOG.md.

**End of Pass 5.**

---

## Pass 6: Test Health & Lint

**Launch a new subagent** for this pass.

### Step 22 — Resolve lint errors

Run lint command. For each error:
1. Genuine fix needed → fix it
2. False positive → add disable comment with brief reason
3. Misconfigured rule → flag for config review

Fix trivial warnings too. Group all lint fixes into a single commit.
Re-run lint command and confirm zero errors.

### Step 23 — Assess test health

Assess the test suite quality:
1. Run tests — confirm all pass
2. Identify redundant tests (same code path, different names)
3. List all exported functions with ZERO test coverage
4. List those with ONLY happy-path coverage
5. Find brittle tests (mock call counts, implementation detail assertions)
6. Assess integration and E2E coverage
7. Check all skipped tests — valid reason or neglected?

Present risk-based prioritisation: highest-risk untested code.

**REVIEW GATE: Present findings. Wait for approval.**

### Step 24 — Apply Pass 6 fixes

Write tests for quick wins only — pure functions that are trivial to test.
Create a GitHub issue: `test: test maturity roadmap` with the full prioritised list.

**Important:** When a test fails, determine whether the CODE is wrong or the TEST expectation is wrong before adjusting. Never blindly change test expectations.

Commit tests. Record Pass 6 results in SANITISATION_LOG.md.

**End of Pass 6.**

---

## Pass 7: Final Measurement & Release

### Step 25 — Final measurements

Take the same measurements as the baseline. Record in SANITISATION_LOG.md under "Final Measurements". Add a "Delta Summary" table comparing before and after for every metric.

Commit: `DOCS: record final measurements and delta summary`

### Step 26 — Validate

Run the complete validation suite:
1. Tests — all pass
2. Lint — zero errors
3. Type checker — zero errors (if applicable)
4. Audit — zero vulnerabilities (or only pre-existing accepted ones)
5. Build — compiles successfully
6. Verify no TODO/FIXME introduced without corresponding issues

### Step 27 — Fix validation failures

Fix any issues found in Step 26. Commit each fix separately. Re-run validation to confirm everything passes.

### Step 28 — Remove temporary rules

Remove the `## SANITISATION MODE (TEMPORARY)` section from CLAUDE.md. Keep all permanent additions (layers, conventions, patterns).

Commit: `META: remove temporary sanitisation rules from CLAUDE.md`

### Step 29 — Push and create PR

Push all commits. Create a PR from `release/sanitisation` to the integration branch:
- Title: `Release: Codebase Sanitisation`
- Description: Include the Delta Summary table from SANITISATION_LOG.md plus a one-paragraph summary of what was covered.

### Step 30 — Handover for manual verification

Tell the user:

> **Before merging this PR, please verify manually:**
> 1. Review the PR diff in GitHub
> 2. Deploy to a preview environment
> 3. Test critical user flows
> 4. Check browser console for errors (especially if CSP was changed)
> 5. Merge when satisfied

---

## Rules

- **Review gates are mandatory.** Never apply fixes without presenting findings first.
- **Triage framework:** Every finding is one of: Fix now (security, bugs, quick wins), Defer (significant effort, low risk → create issue), Document only (intentional deviations → comment in code or CLAUDE.md).
- **Individual commits.** Each fix gets its own commit with AP-ID in the message. This makes the PR reviewable and any fix revertable.
- **Context management.** Use a fresh subagent for each pass (1-6). This prevents hallucinating state from previous passes. SANITISATION_LOG.md provides continuity between passes.
- **Release branch isolation.** All work on `release/sanitisation`. If something goes catastrophically wrong, the branch can be abandoned.
