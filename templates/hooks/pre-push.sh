#!/bin/bash
# Claude Code hook: validates git push commands.
# Blocks pushes to main/master. Prints pre-push checklist for valid pushes.

INPUT=$(cat 2>/dev/null) || true
COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null) || true
[ -z "$COMMAND" ] && exit 0

# Strip heredoc content
CMDS=$(printf '%s' "$COMMAND" | sed '/<<.*EOF/,/^EOF/d; /<<.*HEREDOC/,/^HEREDOC/d' 2>/dev/null) || CMDS="$COMMAND"

# Only fire on git push commands
printf '%s' "$CMDS" | grep -qE '\bgit push\b' 2>/dev/null || exit 0

# Block push to main/master
if printf '%s' "$CMDS" | grep -qE 'git push.*(origin )?(main|master)\b' 2>/dev/null; then
  echo "BLOCKED: Never push directly to main/master. Use staging -> main promotion PR." >&2
  exit 2
fi

echo "PRE-PUSH: tests pass? build passes? named files only? system docs updated?" >&2
exit 0
