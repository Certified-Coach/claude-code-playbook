#!/bin/bash
# Hook: PreToolUse → Edit, Write
# Blocks file edits on staging/main — forces issue branch creation first.
#
# Why: Edit/Write bypass Bash hooks. Without this guard, ad-hoc changes
# can land without the scoping conversation or an issue branch.
set -uo pipefail

INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd // "."')
cd "$CWD" 2>/dev/null || exit 0  # Not a git dir — allow

BRANCH=$(git branch --show-current 2>/dev/null || echo "")

case "$BRANCH" in
  staging|main)
    cat >&2 <<'MSG'
╔══════════════════════════════════════════════════════════════╗
║  EDIT BLOCKED — You are on staging/main                      ║
║                                                              ║
║  All changes require an issue branch.                        ║
║                                                              ║
║  Ask: "Which release is this for? Is it on the critical      ║
║  path?" Then create an issue and branch before editing.      ║
║                                                              ║
║    1. Create or identify the GitHub issue                     ║
║    2. git checkout -b <issue-number>-<description>           ║
║    3. Then make your changes                                 ║
╚══════════════════════════════════════════════════════════════╝
MSG
    echo '{"hookSpecificOutput": {"hookEventName": "PreToolUse", "decision": {"behavior": "block", "reason": "No issue branch. Create a GitHub issue and branch (e.g. git checkout -b 42-fix-description) before editing files."}}}'
    exit 0
    ;;
esac

exit 0
