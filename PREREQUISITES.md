# Prerequisites — Before You Start

This guide gets you from zero to ready. If you already have Claude Code, git, and GitHub CLI working, skip to [START-HERE.md](START-HERE.md).

## 1. Claude Code

Install Claude Code (Anthropic's CLI for Claude):

```bash
# macOS / Linux
npm install -g @anthropic-ai/claude-code

# Or via Homebrew
brew install claude-code
```

Verify: `claude --version` — must be **2.1.83 or later** (required for `SessionStart` hook).

If your version is older: `claude update`

You need a Claude account with Claude Code access. See [claude.com/claude-code](https://claude.com/claude-code).

## 2. Git

Most systems have git pre-installed. If not:

```bash
# macOS
xcode-select --install

# Ubuntu/Debian
sudo apt install git

# Windows (WSL recommended)
sudo apt install git
```

Verify: `git --version`

Configure your identity (if not already done):
```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

## 3. GitHub CLI (`gh`)

The GitHub CLI lets Claude create repos, issues, milestones, and PRs programmatically.

```bash
# macOS
brew install gh

# Ubuntu/Debian
sudo apt install gh

# Windows (in WSL)
sudo apt install gh
```

Verify: `gh --version`

### Authenticate with GitHub

```bash
gh auth login
```

Choose:
- GitHub.com (not Enterprise)
- HTTPS (recommended)
- Authenticate with a web browser (easiest)

Verify: `gh auth status` — should show your username and token scopes.

### Required token scopes

The default `gh auth login` grants enough for most operations. If you need project board access, you may need to add scopes:

```bash
gh auth refresh -s project
```

## 4. Node.js and a package manager

Most modern projects need Node.js. Install the LTS version:

```bash
# Via nvm (recommended — manages multiple versions)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
nvm install --lts

# Or directly
# macOS: brew install node
# Ubuntu: sudo apt install nodejs npm
```

Verify: `node --version && npm --version`

### Package manager (pick one)

```bash
# pnpm (recommended — fast, disk-efficient)
npm install -g pnpm

# Or yarn
npm install -g yarn

# Or just use npm (already installed with Node)
```

## 5. Secrets management (optional but recommended)

For API keys, database URLs, and other secrets:

### Option A: 1Password CLI (recommended for teams)
```bash
# macOS
brew install 1password-cli

# Authenticate
op account add
op signin
```

Claude can then read secrets with `op item get "Item Name" --field "field"` — no secrets in plain text files.

### Option B: `.env` files (simpler, solo developers)
- Create `.env` for local development (gitignored)
- Create `.env.example` for documenting required variables (committed)
- Never commit `.env` to git

## 6. Create your project directory

```bash
mkdir my-project
cd my-project
git init
```

## 7. Create the GitHub repo

```bash
# Public repo
gh repo create my-project --public --source=. --push

# Private repo
gh repo create my-project --private --source=. --push
```

## Ready?

You now have:
- Claude Code installed and working
- Git configured with your identity
- GitHub CLI authenticated
- Node.js and a package manager
- A git repo connected to GitHub

Next: Open your project in Claude Code (`claude` in your terminal) and follow [SETUP-PROMPT.md](SETUP-PROMPT.md).
