# Setup Prompt

Copy everything below the line and paste it into Claude Code.

---

I'd like you to set up a new project using the Claude Code Playbook at ~/claude-code-playbook

Work through these phases in order. Complete each phase before moving to the next. Ask me questions when you need my input. If anything fails, explain what went wrong and how to fix it.

## Phase 0: Environment check

Ask what programming language and framework the project uses. Then only check for the tools relevant to that stack (e.g., Node.js projects need node/pnpm, Python projects need python/pip, Go projects need go, etc.). Don't assume Node.js.

Check what's installed and set up anything missing:

1. **Git:** Run `git --version`. If not installed, guide me through installing it for my OS.
2. **GitHub CLI:** Run `gh --version`. If not installed, guide me through:
   - Installing gh (brew install gh / apt install gh / etc.)
   - Authenticating: `gh auth login` (walk me through the prompts)
   - Verify: `gh auth status`
3. **Language runtime and package manager:** Based on the stack, check for the relevant tools (e.g., `node --version` and `pnpm --version` for Node.js, `python --version` and `pip --version` for Python, `go version` for Go). If not installed, guide me through installing them.
4. **Git config:** Check `git config user.name` and `git config user.email`. If not set, ask me for my name and email and configure them.

Report what was found and what was installed.

## Phase 1: Interview

Ask me these questions one at a time. Wait for my answer before moving on:

1. What is this project called? (one word or short name for the repo)
2. In one sentence, what does it do?
3. Who is it for? (the target users)
4. Public or private repo?
5. What tech stack? (if you're unsure, tell me what you're building and I'll recommend one)
6. Are you working solo or in a team?
7. Will this project ship releases to users, or is it internal/documentation/config-only?
8. Do you have existing documents to feed in? (strategy docs, feature lists, research, wireframes, business plans — anything)
9. What does "done" look like for the first version? What's the first thing users should be able to do?

## Phase 1b: Workflow profile

Based on the interview answers, determine which workflow profile fits this project. Present the two options, explain what each includes, and recommend one — but let me choose.

### Profile A: Structured delivery

**Use when:** The project ships releases, has multiple concerns in flight, or benefits from PR-based review — regardless of team size. A solo developer building a SaaS product needs this just as much as a team of five.

Includes:
- **Staging branch** — `feature/ → staging → main` promotion workflow
- **PR workflow** — all changes go through pull requests targeting staging
- **Full bash-guard** — blocks direct push to main, enforces PR discipline, dead-branch guard
- **Milestones and labels** — release tracking via GitHub milestones
- **Issue templates and project board**

### Profile B: Direct push

**Use when:** The project is simple enough that PRs add overhead without value — documentation repos, config-only repos, internal tools with no deployment pipeline, or early prototypes that haven't reached release cadence yet.

Includes:
- **Push to main** — no staging branch, no PR workflow
- **Reduced bash-guard** — keeps destructive-action guards (force push, reset --hard, clean -f, --no-verify, git add -A) but removes staging/PR rules and dead-branch guard
- **No milestones or labels** (optional — can add later)
- **No issue templates or project board** (optional — can add later)

**Note:** Profile B projects can upgrade to Profile A later. If the project grows in complexity or starts shipping releases, re-run the relevant Phase 2 steps to add staging, labels, and milestones.

### What both profiles share

- CLAUDE.md as the constitution
- Memory system
- Session-start hook
- Engineering plan and roadmap
- Health check skills
- Commit message prefixes

**Tell me which profile you recommend and why, then let me confirm before continuing.**

## Phase 2: GitHub setup

Based on my answers and chosen workflow profile:

1. **Initialise the repo:**
   ```bash
   git init
   ```

2. **Create the GitHub repo:**
   ```bash
   gh repo create [name] --[public/private] --source=. --push --description "[description]"
   ```

3. **Create staging branch** *(Profile A only — skip for Profile B):*
   ```bash
   git checkout -b staging
   git push -u origin staging
   ```

4. **Set up labels** *(Profile A only — skip for Profile B, can be added later):*
   Read `~/claude-code-playbook/templates/github/labels.json` and create each label:
   ```bash
   gh label create "[name]" --color "[color]" --description "[desc]"
   ```

5. **Copy templates** from the playbook to the project:
   - `~/claude-code-playbook/templates/github/workflows/ci.yml` → `.github/workflows/`
   - `~/claude-code-playbook/templates/github/workflows/hygiene.yml` → `.github/workflows/`
   - *(Profile A only)* `~/claude-code-playbook/templates/github/ISSUE_TEMPLATE/` → `.github/ISSUE_TEMPLATE/`
   - *(Profile A only)* `~/claude-code-playbook/templates/github/pull_request_template.md` → `.github/`

6. **Create milestones** *(Profile A only — skip for Profile B, can be added later):*
   ```bash
   gh api repos/[owner]/[repo]/milestones --method POST -f title="R0 — [first release name]" -f description="[from interview]"
   gh api repos/[owner]/[repo]/milestones --method POST -f title="R1 — [second release name]"
   gh api repos/[owner]/[repo]/milestones --method POST -f title="R2 — [third release name]"
   ```

7. **Create a project board** *(Profile A only — skip for Profile B):*
   Guide me through creating a GitHub Project (V2) via the UI if the API is complex, or create via API if possible.

## Phase 3: Project files

1. **CLAUDE.md** — Read `~/claude-code-playbook/templates/CLAUDE.md.template` and create a CLAUDE.md in the repo root, filled in with everything from the interview. Include:
   - Operating mode
   - Current release and targets
   - Project identity
   - Tech stack (be specific — versions, package manager)
   - Key conventions for this stack
   - How to run the project (dev, build, test commands)
   - Starter trigger table (if touching X, read Y)

2. **Memory system:**
   - Create the memory directory for this project
   - Create `MEMORY.md` from `~/claude-code-playbook/templates/MEMORY.md.template`
   - Create `project_context.md` — save everything from the interview as a project memory
   - Create `user_profile.md` — ask me about my preferences (concise/verbose, emoji preference, how autonomous should Claude be)

3. **Documentation structure:**
   - Create `docs/design/` and `docs/system/`
   - Create an engineering plan from `~/claude-code-playbook/templates/engineering-plan.md` — fill in what we know
   - Create a roadmap from `~/claude-code-playbook/templates/roadmap.md` — fill in the releases

4. **Git hooks:**
   - Create `.githooks/pre-commit` with a basic check (adapt to the tech stack — lint, format, type check)
   - Run `git config core.hooksPath .githooks`
   - Make it executable: `chmod +x .githooks/pre-commit`

5. **Claude Code hooks (process enforcement):**
   - Create `.claude/hooks/` directory
   - Copy `~/claude-code-playbook/templates/hooks/bash-guard.sh` → `.claude/hooks/bash-guard.sh`
   - Copy `~/claude-code-playbook/templates/hooks/session-start.sh` → `.claude/hooks/session-start.sh`
   - Copy `~/claude-code-playbook/templates/hooks/settings.json` → `.claude/settings.json`
   - Make hooks executable: `chmod +x .claude/hooks/*.sh`
   - **Profile A:** Use the full bash-guard as-is. It enforces: no push to main, no force push, no --admin bypass, no skipping hooks, dead-branch guard, PR discipline, release scope gate.
   - **Profile B:** After copying, remove the following sections from `.claude/hooks/bash-guard.sh`:
     - "Block push to main/master" (pushing to main is the workflow)
     - "Branch discipline" / dead-branch guard (no PRs to check)
     - "PR discipline" / `gh pr create` rules (no staging branch)
     - Keep: force push block, destructive ops block, --no-verify block, specific file staging, --admin bypass block, release health gate

6. **Health check skills:**
   - Read `~/claude-code-playbook/practices/sanitisation/skills-installer.md`
   - Install all 6 skills into `.claude/skills/`
   - These provide: `/health-check`, `/bloat-check`, `/dry-check`, `/security-check`, `/arch-check`, `/test-health`

7. **Screenshot tool:**
   - Install `cc-snap` for desktop screenshots: `cp ~/claude-code-playbook/extras/cc-snap.sh ~/.local/bin/cc-snap && chmod +x ~/.local/bin/cc-snap`
   - Verify `~/.local/bin` is on PATH (it usually is on Ubuntu/macOS; if not, add it)
   - Add to the project CLAUDE.md trigger table: `| cc-snap | Capture desktop screen | cc-snap → read ~/screenshot.png |`
   - This lets Claude take and view screenshots on macOS, WSL, Windows (Git Bash), and Linux

8. **Permissions — how autonomous should Claude be?**

   The bash-guard hook (step 5) is your safety net — it blocks destructive commands before they execute. With the guard in place, you can safely give Claude broader permissions so it doesn't prompt you for every command.

   Explain the three options and ask the user to choose:

   **Option 1: Guarded autonomy (recommended)**
   Claude can run any bash command and edit any file without prompting, but the bash-guard hook blocks dangerous operations. This is the best balance — fast iteration with mechanical safety.

   Add to `.claude/settings.json`:
   ```json
   "permissions": {
     "allow": [
       "Bash",
       "Read",
       "Edit",
       "Write",
       "WebFetch(domain:*)"
     ]
   }
   ```

   **Option 2: Selective permissions**
   Only pre-approve specific commands. Claude will still prompt for anything not listed. Good for teams that want tighter control.

   Add to `.claude/settings.json`:
   ```json
   "permissions": {
     "allow": [
       "Read",
       "Edit",
       "Bash(git *)",
       "Bash(npm *)",
       "Bash(pnpm *)",
       "Bash(cc-snap*)",
       "Bash(ls *)",
       "Bash(gh *)"
     ]
   }
   ```
   Adapt the list to the project's tech stack (e.g., `Bash(python *)`, `Bash(go *)`, `Bash(cargo *)`).

   **Option 3: Default (prompt for everything)**
   Claude asks permission for every bash command and file edit. Safe but slow. You can switch to Option 1 or 2 later by editing `.claude/settings.json`.

   **Important notes to share with the user:**
   - Permissions in `.claude/settings.json` are shared with the team (committed to git). Personal overrides go in `.claude/settings.local.json` (gitignored).
   - `deny` rules always win over `allow` rules, at any scope.
   - You can switch modes mid-session with `Shift+Tab`.
   - The bash-guard hook runs regardless of permission level — even with full Bash allowed, destructive operations are still blocked.

9. **Environment:**
   - Create `.gitignore` appropriate for the tech stack
   - Create `.env.example` listing any required environment variables
   - Create `.env` (ensure it's in .gitignore)

## Phase 4: Feed existing context

If the user said they have existing documents:

1. Ask them to paste or point to each document
2. For each document, extract:
   - Key decisions and rationale
   - Goals and success metrics
   - Constraints and dependencies
   - User personas or audience definitions
   - Feature lists or requirements
3. Save each as an appropriate memory file:
   - Decisions → `project_decisions.md`
   - Strategy → `project_strategy.md`
   - Feature list → use it to create GitHub issues in Phase 5
   - Personas → `project_personas.md`

## Phase 5: Initial backlog

1. Based on the interview and any existing documents, create 5-10 starter issues:
   ```bash
   gh issue create --title "FEAT: [title]" --body "[from template]" --label enhancement --milestone "R0 — [name]"
   ```

2. Create at least one issue for each category:
   - A feature issue (the first thing to build)
   - An engineering issue (project setup, CI configuration)
   - A documentation issue (if docs need writing)

3. Tell me which issue to start with and why.

## Phase 6: Project scaffold (if new project)

If this is a brand new project with no code:

1. Based on the tech stack, create the initial project scaffold:
   - `package.json` (or equivalent)
   - TypeScript config (if applicable)
   - Linter config
   - Test framework config
   - Basic folder structure

2. Install dependencies

3. Verify: `dev`, `build`, and `test` commands all work

## Phase 7: First commit

1. Stage everything: `git add -A`
2. Commit: `git commit -m "META: initialise project with Claude Code Playbook"`
3. Push:
   - **Profile A:** `git push origin staging`
   - **Profile B:** `git push origin main`

## Phase 8: Handover

1. Read `~/claude-code-playbook/CHEAT-SHEET.md` and show me the highlights
2. Summarise everything that was created:
   - Files in the repo
   - GitHub milestones and issues
   - What to do next
3. Tell me: "Your project is set up. Here's what you can now ask me to do..."
4. Ask: "Ready to start building? Which issue shall we start with?"
