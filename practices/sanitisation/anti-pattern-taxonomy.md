# Anti-Pattern Taxonomy

27 anti-patterns across 7 domains. This is the detection catalogue — what the sanitisation process looks for and why it matters.

## Domain 1: Structural Bloat

| ID | Anti-Pattern | What to look for | Risk |
|---|---|---|---|
| AP-1.1 | Verbose implementation | Functions >30 lines, files >300 lines, unnecessary intermediate variables | Readability, maintainability |
| AP-1.2 | Over-abstraction | Single-implementation interfaces, pass-through wrappers, helper-of-helper chains | Complexity without benefit |
| AP-1.3 | Reinvented wheels | Custom utilities that duplicate functionality in declared dependencies | Maintenance burden, bugs |
| AP-1.4 | Dead code | Unused exports, orphan files, commented-out blocks, unreachable branches | Confusion, false grep results |
| AP-1.5 | Phantom dependencies | Declared but unused packages, undeclared but transitively imported packages | Supply chain risk, install bloat |

## Domain 2: Duplication & Missed Consolidation

| ID | Anti-Pattern | What to look for | Risk |
|---|---|---|---|
| AP-2.1 | Copy-paste code | Identical or near-identical blocks across files (use jscpd or similar) | Bug fixes missed in copies |
| AP-2.2 | Parallel implementations | Same concept implemented differently in different features | Inconsistent behaviour |
| AP-2.3 | Missing shared modules | Repeated patterns that should be extracted to a shared utility | Drift between copies |

## Domain 3: Architectural Drift

| ID | Anti-Pattern | What to look for | Risk |
|---|---|---|---|
| AP-3.1 | Layer violations | Imports that cross architectural boundaries in the wrong direction | Coupling, extraction difficulty |
| AP-3.2 | Data access boundary breaks | Database calls from UI components, ORM calls outside the data layer | Testability, portability |
| AP-3.3 | Business logic leakage | Domain logic in API routes, UI components, or utility files | Logic scattered across layers |
| AP-3.4 | N+1 query patterns | Database queries inside loops, sequential queries that could be parallel | Performance, DoS vectors |
| AP-3.5 | Pattern inconsistencies | Same task done different ways across features without justification | Onboarding confusion |

## Domain 4: Security & Supply Chain

| ID | Anti-Pattern | What to look for | Risk |
|---|---|---|---|
| AP-4.1 | Known CVEs | Vulnerabilities in dependencies (run your package manager's audit command) | Exploitable vulnerabilities |
| AP-4.2 | Hardcoded secrets | API keys, tokens, passwords in source code or config files | Credential exposure |
| AP-4.3 | Missing input validation | User input passed to database queries, file operations, or external APIs without validation | Injection, data corruption |
| AP-4.4 | Weak cryptography | Math.random() for tokens, missing CSRF protection, permissive CSP | Authentication bypass |
| AP-4.5 | Insecure defaults | Debug modes in production, verbose error messages, permissive CORS | Information leakage |

## Domain 5: Test Quality

| ID | Anti-Pattern | What to look for | Risk |
|---|---|---|---|
| AP-5.1 | Coverage gaps | Exported functions with zero tests, critical paths with no integration tests | Silent regressions |
| AP-5.2 | Brittle tests | Mock call count assertions, implementation detail testing, exact string matching | Tests break on refactoring |
| AP-5.3 | Redundant tests | Same code path tested multiple times with trivially different inputs | Wasted CI time, false confidence |

## Domain 6: Context & Workflow Integrity

| ID | Anti-Pattern | What to look for | Risk |
|---|---|---|---|
| CW-6.1 | Stale documentation | Docs that describe code that no longer exists or works differently | Wrong decisions based on docs |
| CW-6.2 | Missing CLAUDE.md sections | No architectural layers, no trigger table, no run commands | Claude works without context |
| CW-6.3 | Undocumented decisions | Architectural choices with no recorded rationale | Decisions reversed accidentally |

## Domain 7: Missing Controls

| ID | Anti-Pattern | What to look for | Risk |
|---|---|---|---|
| MC-7.1 | No pre-commit hooks | Code pushed without lint, format, or type checks | Quality drift |
| MC-7.2 | No CI pipeline | No automated checks on PR | Broken code merged |
| MC-7.3 | No security scanning | No dependency audit in CI, no secret scanning | Vulnerabilities merged |
| MC-7.4 | No performance baseline | No bundle size tracking, no query count monitoring | Silent performance regression |
| MC-7.5 | No architectural enforcement | No import rules, no layer boundary checks | Architecture erodes over time |

## How to use this taxonomy

Each pass in the sanitisation process targets specific anti-patterns. When a finding is reported, it references the AP-ID so you can trace it back to this catalogue.

The taxonomy is also useful outside of full sanitisation — use it as a checklist when reviewing PRs or when something "feels wrong" in the codebase but you can't articulate what.

## Adapting the taxonomy

Not all anti-patterns apply to every project:
- **Small projects** may skip AP-3.x (architecture) if there are no defined layers yet
- **Solo projects** may deprioritise AP-5.2 (brittle tests) if refactoring is infrequent
- **Pre-launch projects** should prioritise AP-4.x (security) and AP-1.4/1.5 (dead code/deps)
- **Team projects** should prioritise AP-3.5 (inconsistencies) and AP-6.x (documentation)
