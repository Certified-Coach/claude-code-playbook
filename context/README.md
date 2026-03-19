# Context — Your existing documents go here

Drop any documents you have into this folder. Claude will read them during setup to understand your project — but will treat them as **informational, not authoritative**.

## Why "informational, not authoritative"?

Your existing documents might be:
- **Stale** — written months ago, no longer accurate
- **Aspirational** — describing what you want, not what exists
- **Inconsistent** — different documents contradict each other
- **Incomplete** — missing key decisions or technical details

That's fine. Claude will:
1. Read everything you provide
2. Extract what's useful (goals, decisions, feature lists, constraints)
3. Ask you to confirm or correct key assumptions
4. Build fresh, accurate project documents from verified information
5. Save the validated context as memory files

## What to put here

Drop any of these — the more context, the better:

### Strategy & business
- Business plan or pitch deck (PDF, MD, or pasted text)
- Market research or competitive analysis
- User personas or audience definitions
- Revenue model or pricing strategy

### Product & design
- Feature list or product requirements
- Wireframes or mockups (describe them or link to Figma)
- User journey maps
- Priority matrix (what's important vs what's urgent)

### Engineering
- Existing engineering plan (even if stale or failed)
- Tech stack decisions and rationale
- Architecture diagrams or system design docs
- API specifications
- Database schema or data model

### Previous attempts
- Post-mortems from failed builds
- What went wrong and why
- What worked and should be kept
- Lessons learned

## File naming

No strict naming required. Use whatever makes sense:
```
context/
├── business-plan.md
├── feature-list.md
├── engineering-plan-v2.md
├── previous-attempt-postmortem.md
├── personas.md
├── competitor-analysis.md
└── tech-stack-evaluation.md
```

## What happens during setup

When you run the setup prompt, Phase 4 specifically handles these documents:

1. Claude reads each file
2. Extracts key decisions, goals, features, constraints
3. Asks you: "Is this still accurate? Has anything changed?"
4. Creates validated memory files from confirmed information
5. Uses feature lists to seed the GitHub issue backlog
6. Flags contradictions between documents for you to resolve

**The result:** Your scattered, possibly stale documents become a clean, verified set of project memory files and GitHub issues. Nothing is lost, but nothing is assumed to be correct without your confirmation.
