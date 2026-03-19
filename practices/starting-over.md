# Starting Over — When You Have a Failed Codebase

You've tried to build this before. Maybe multiple times. The codebase grew, documentation didn't, and now it's unmaintainable. Here's how to start fresh without losing what you learned.

## Don't throw everything away

Your failed attempt contains valuable information:
- **What worked** — the parts that were stable, the patterns that held up
- **What broke** — the architectural decisions that caused pain
- **Domain knowledge** — the business logic is correct even if the code isn't
- **Edge cases discovered** — bugs you fixed reveal requirements you didn't know about

## Before writing new code

### 1. Post-mortem the old codebase

Write a document (put it in `context/`) answering:
- What was the original architecture?
- Where did complexity accumulate?
- What were the pain points for development?
- What broke in production?
- What would you keep if you could?
- What would you never do again?

### 2. Extract the domain knowledge

The old codebase has business logic buried in it. Before deleting anything:
- List every entity (user, order, product, etc.) and their relationships
- List every workflow (signup → onboarding → active)
- List every integration (payment, email, auth)
- List every rule ("users can't do X unless Y")

Save these in `context/`. They're the requirements for the new build.

### 3. Identify what was actually working

Some parts of the old codebase might be portable:
- Database schema (might need cleanup but the structure is sound)
- API contracts (if consumers depend on them, keep the interface)
- Test cases (the tests describe correct behaviour even if the code doesn't)
- Configurations (CI, deployment, environment setup)

### 4. Define what "done" looks like differently this time

The old approach failed. What changes?
- Smaller releases (don't build everything before shipping)
- Documentation alongside code (not "we'll document later")
- Tests from the start (not "we'll add tests later")
- Clear architecture boundaries (not "we'll refactor later")

## The rebuild sequence

1. **Set up the playbook** (SETUP-PROMPT.md) — start with process
2. **Feed your context** — dump old docs, post-mortem, domain knowledge into `context/`
3. **Let Claude extract and verify** — it reads your context, you confirm what's still true
4. **Build the thinnest possible first release** — not the whole system, just the core loop
5. **Ship it to one user** — get feedback before building more
6. **Expand incrementally** — each release adds one capability

## Common mistakes when rebuilding

- **"This time we'll get the architecture right first"** — you won't know the right architecture until you've built something. Start simple, refactor when you have evidence.
- **"We need to replicate all the old features"** — you probably don't. Half of them were unused. Build what users actually need.
- **"Let's use [new shiny technology]"** — use boring technology that works. The old build didn't fail because of the tech stack.
- **"We'll move faster this time because we know the domain"** — you'll move faster initially, then hit the same walls if you don't change the process.

## What the playbook gives you that you didn't have before

- A CLAUDE.md that keeps Claude aligned session after session
- Memory that preserves decisions across conversations
- A release plan that prevents scope creep
- Documentation that stays current with the code
- Git discipline that creates traceability
- Quality gates that catch drift early
