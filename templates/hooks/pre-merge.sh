#!/bin/bash
# Claude Code hook: prints pre-merge doc checklist for gh pr merge commands.

INPUT=$(cat 2>/dev/null) || true
COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null) || true
[ -z "$COMMAND" ] && exit 0

CMDS=$(printf '%s' "$COMMAND" | sed '/<<.*EOF/,/^EOF/d; /<<.*HEREDOC/,/^HEREDOC/d' 2>/dev/null) || CMDS="$COMMAND"

printf '%s' "$CMDS" | grep -qE '\bgh pr merge\b' 2>/dev/null || exit 0

echo "PRE-MERGE: CI passing? System docs updated? Component API docs updated? Issue metadata complete?" >&2
exit 0
