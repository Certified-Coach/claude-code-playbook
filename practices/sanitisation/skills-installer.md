# Skills Installer

Paste this single prompt into Claude Code to install all 6 sanitisation skills. Run once per project.

> Install 6 health check skills for codebase sanitisation. Create each file below in .claude/skills/ and make them available as slash commands.
>
> **Skill 1: .claude/skills/bloat-check/SKILL.md**
>
> Name: bloat-check
> Description: Find oversized files, long functions, unnecessary abstractions, and reinvented wheels.
>
> Procedure:
> 1. Find all source files exceeding 300 lines. For each, assess whether it can be split by responsibility or is justified (e.g., a compound component with tightly-related sub-components).
> 2. Find all functions exceeding 30 lines. Identify extractable sub-functions.
> 3. Search for custom utility implementations that duplicate functionality available in declared dependencies.
> 4. Find interfaces/abstract classes with exactly one implementation — justified or unnecessary?
> 5. Find pass-through wrapper functions that add no logic.
> 6. Find unnecessary intermediate variables (assigned once, used once on the next line).
> 7. Present findings with file paths, line numbers, and specific recommended action. Do NOT auto-fix.
>
> **Skill 2: .claude/skills/dry-check/SKILL.md**
>
> Name: dry-check
> Description: Find code duplication and suggest shared modules.
>
> Procedure:
> 1. Run jscpd (or equivalent duplication detector) with --min-lines 5 --min-tokens 50.
> 2. Report total duplication percentage, clone count, and duplicated line count.
> 3. List all clone pairs sorted by size (largest first).
> 4. For each clone pair, classify as: Tier 1 (extract now — identical, same purpose), Tier 2 (extract later — similar, may diverge), or Tier 3 (acceptable — intentional duplication in different domains).
> 5. For Tier 1 items, propose specific shared module with file path and extraction boundaries.
> 6. Present findings. Do NOT auto-fix.
>
> **Skill 3: .claude/skills/security-check/SKILL.md**
>
> Name: security-check
> Description: Check for CVEs, secrets, input validation gaps, and weak cryptography.
>
> Procedure:
> 1. Run the package manager's audit command. Report all vulnerabilities by severity.
> 2. Search source code for hardcoded strings that look like API keys, tokens, passwords, or connection strings.
> 3. Search for uses of weak random number generation for security purposes (e.g., Math.random for tokens).
> 4. For every API route and form handler, check: is user input validated? Are there length limits? Are IDs format-checked?
> 5. Check for SQL injection, XSS, command injection patterns.
> 6. Check security headers: CSP, HSTS, cookie attributes.
> 7. Present findings with severity ratings. Do NOT auto-fix.
>
> **Skill 4: .claude/skills/arch-check/SKILL.md**
>
> Name: arch-check
> Description: Validate architectural boundaries, find layer violations, N+1 queries, and logic leakage.
>
> Procedure:
> 1. Read CLAUDE.md for architectural layer definitions. If none exist, analyse the codebase and propose layers.
> 2. Check every import in the source tree for layer violations (imports crossing boundaries in the wrong direction).
> 3. Find database/ORM calls outside the expected data access layer.
> 4. Find business logic in API routes, UI components, or utility files.
> 5. Find N+1 query patterns — database queries inside loops, sequential queries that could be parallel.
> 6. Find pattern inconsistencies — same task done different ways across features without justification.
> 7. Present findings with file paths, line numbers, and severity. Do NOT auto-fix.
>
> **Skill 5: .claude/skills/test-health/SKILL.md**
>
> Name: test-health
> Description: Assess test suite quality — coverage gaps, brittle tests, redundant tests.
>
> Procedure:
> 1. Run the test suite. Report total, passing, failing, skipped.
> 2. Identify redundant tests — same code path tested with trivially different inputs.
> 3. List all exported functions and endpoints with ZERO test coverage at any level.
> 4. List those with ONLY happy-path coverage (no error or boundary tests).
> 5. Find brittle tests — mock call count assertions, implementation detail testing, exact string matching on error messages.
> 6. Check all skipped tests — valid reason or neglected?
> 7. Present a risk-based prioritisation: highest-risk untested code, not just count of missing tests.
>
> **Skill 6: .claude/skills/health-check/SKILL.md**
>
> Name: health-check
> Description: Run all 5 health checks and produce a combined summary report.
>
> Procedure:
> 1. Run /bloat-check
> 2. Run /dry-check
> 3. Run /security-check
> 4. Run /arch-check
> 5. Run /test-health
> 6. Produce a combined summary with: total findings by severity, top 5 highest-priority items, and a recommended action plan.
>
> After creating all 6 skills, verify they exist with: ls -la .claude/skills/*/SKILL.md
