#!/bin/bash
# Hook: PreToolUse → Bash (filters for git commit)
# If code is being committed without a planning session, posts a note
# on the GitHub issue documenting that scope was accepted as-is.
#
# Does NOT block the commit — informational only.
set -uo pipefail

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Only act on git commit commands
case "$COMMAND" in
  git\ commit*) ;;
  *) exit 0 ;;
esac

MARKER_DIR="/tmp/claude-plan-sessions"

# If planning was done (marker exists as .planned or .planning), nothing to do
if [ -f "${MARKER_DIR}/${SESSION_ID}.planned" ] || [ -f "${MARKER_DIR}/${SESSION_ID}.planning" ]; then
  exit 0
fi

# No planning occurred — detect issue number from branch
BRANCH=$(git branch --show-current 2>/dev/null || echo "")
ISSUE_NUMBER=$(echo "$BRANCH" | grep -oE '^[0-9]+' || echo "")

if [ -z "$ISSUE_NUMBER" ]; then
  # Can't determine issue — skip silently
  exit 0
fi

# Check if we've already posted this message for this session
NOTED_FILE="${MARKER_DIR}/${SESSION_ID}.no-plan-noted"
if [ -f "$NOTED_FILE" ]; then
  exit 0
fi

# Post the "accepted as-is" comment
gh issue comment "$ISSUE_NUMBER" --body "### Scope accepted as-is — no planning session

Code is being committed for this issue without a formal planning session. The issue's existing scope and acceptance criteria were accepted without further planning or modification.

_Recorded automatically by plan lifecycle hook — $(date -u +%Y-%m-%dT%H:%M:%SZ)_" 2>/dev/null || true

# Mark as noted so we don't repeat
mkdir -p "$MARKER_DIR"
touch "$NOTED_FILE"

echo "No-plan notice posted to #${ISSUE_NUMBER}" >&2

exit 0
