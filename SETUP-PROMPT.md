# Setup Prompt

Two options depending on your setup.

## Option A: Full setup (recommended)

Clone the playbook locally first:
```bash
git clone https://github.com/Certified-Coach/claude-code-playbook.git ~/claude-code-playbook
```

Then open your project directory in Claude Code and paste everything below the line:

---

I'd like you to set up this project using the Claude Code Playbook at ~/claude-code-playbook

Please work through these phases in order. Complete each phase before moving to the next. Ask me questions when you need my input.

## Phase 1: Interview

Ask me:
- What is this project? (name, one-line description)
- What problem does it solve? Who is it for?
- What's the tech stack? (or should we choose one together?)
- Am I working solo or in a team?
- Do I have existing context to feed in? (strategy docs, feature lists, research, wireframes)
- What does the first release look like?
- What are the immediate priorities?

## Phase 2: Git + GitHub setup

Based on my answers:

1. **Initialise the repo** (if not already done): `git init`

2. **Create GitHub repo** (if not already done):
   ```
   gh repo create [name] --public/--private --description "[description]"
   ```

3. **Create branch structure:**
   - Create `staging` branch: `git checkout -b staging && git push -u origin staging`
   - Set staging as the default PR target

4. **Copy GitHub templates** from the playbook:
   - Copy `templates/github/ISSUE_TEMPLATE/` to `.github/ISSUE_TEMPLATE/`
   - Copy `templates/github/pull_request_template.md` to `.github/`
   - These give us structured issue creation (feature, bug, engineering)

5. **Create a GitHub Project board:**
   ```
   gh api graphql -f query='mutation { createProjectV2(input: { ownerId: "[owner-id]", title: "[Project Name]" }) { projectV2 { id number } } }'
   ```
   - Or guide me through creating it in the GitHub UI if the API is complex

6. **Create initial milestones** based on the releases we discussed:
   ```
   gh api repos/[owner]/[repo]/milestones --method POST -f title="R0 — [name]" -f due_on="[date]"
   ```
   - Create one milestone per release we defined

7. **Create initial labels** (if they don't exist):
   - `enhancement`, `bug`, `documentation`, `engineering`, `design`, `security`

## Phase 3: Project files

1. **CLAUDE.md** — create from the playbook template, filled with my project's details. Include:
   - Operating mode
   - Current release + targets
   - Project identity and tech stack
   - Key conventions
   - Starter docs trigger table
   - Running the project commands

2. **Memory system:**
   - Create memory directory
   - Create `MEMORY.md` index
   - Create `project_context.md` — capture everything from the interview
   - Create `user_profile.md` — my preferences, role, expertise
   - If I shared strategy/feature docs, save key decisions as memory files

3. **Git hooks:**
   - Create `.githooks/pre-commit` with a basic quality check
   - Run `git config core.hooksPath .githooks`

4. **Documentation structure:**
   - Create `docs/` directory with subdirectories: `design/`, `system/`, `reference/`
   - Create a starter engineering plan from `templates/engineering-plan.md`
   - Create a starter roadmap from `templates/roadmap.md`
   - Populate both with the releases and priorities from our interview

5. **`.gitignore`** appropriate for the tech stack

## Phase 4: Secrets and environment

1. **Check for 1Password CLI** (`op --version`) — if available, guide me through storing API keys
2. **Create `.env.example`** listing required environment variables (no values)
3. **Create `.env`** (gitignored) with placeholder values
4. **Note any external services** that need accounts (hosting, database, auth, email)

## Phase 5: Initial backlog

1. **Create 5-10 starter issues** from our discussion, using the issue templates:
   ```
   gh issue create --title "FEAT: [title]" --body "[body]" --label enhancement --milestone "R0 — [name]"
   ```
2. **Add issues to the project board** if we created one
3. **Prioritise** — which issue do we start with?

## Phase 6: First commit

1. Stage all created files
2. Commit: `META: initialise project with Claude Code Playbook`
3. Push to staging
4. Verify GitHub has: repo, milestones, issues, project board, templates

## Phase 7: Handover

1. Show me the cheat sheet from `~/claude-code-playbook/CHEAT-SHEET.md`
2. Summarise what was created
3. Recommend what to build first based on the roadmap
4. Ask: "Ready to start building?"

---

## Option B: Minimal setup (no playbook clone needed)

Paste this into Claude Code if you don't want to clone the playbook repo:

---

I want to set up structured working practices for my project. Please:

1. Interview me about my project (name, tech stack, priorities)
2. Create a CLAUDE.md with project context, conventions, and current targets
3. Set up a memory system for persistent decisions
4. Create a GitHub repo with milestones, labels, issue templates, and a project board
5. Create a starter engineering plan and roadmap
6. Create 5-10 initial issues from our discussion
7. Set up git hooks for quality gates
8. Make the first commit

Start by asking me about the project.
