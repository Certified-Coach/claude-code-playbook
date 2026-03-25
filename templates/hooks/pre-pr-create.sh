#!/bin/bash
# Hook: PreToolUse → Bash (filters for PR creation)
# BLOCKS PR creation unless merge strategy is specified.
# Forces Claude to ask the user "auto-merge or manual review?" first.
#
# ADAPT: If your project uses a wrapper script (e.g. scripts/create-pr.sh),
# add it to the case pattern below.
set -uo pipefail

INPUT=$(cat 2>/dev/null) || true
COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null) || true
[ -z "$COMMAND" ] && exit 0

# Strip heredoc content to avoid false positives on commit messages
CMDS=$(printf '%s' "$COMMAND" | sed '/<<.*EOF/,/^EOF/d; /<<.*HEREDOC/,/^HEREDOC/d' 2>/dev/null) || CMDS="$COMMAND"

# Only act on PR creation commands
case "$CMDS" in
  *gh\ pr\ create*) ;;
  *) exit 0 ;;
esac

# Check if merge strategy is already specified
# --merge-now: auto-merge after CI passes
# --review USER: request manual review from USER
if echo "$CMDS" | grep -qE '\-\-merge-now|\-\-review' 2>/dev/null; then
  # Strategy already specified — allow
  exit 0
fi

# No strategy specified — BLOCK
cat >&2 <<'MSG'
BLOCKED: PR creation requires merge strategy.
Ask the user: "Auto-merge or manual review?"
Then use: gh pr create --merge-now  OR  gh pr create --review USER
MSG
exit 2
