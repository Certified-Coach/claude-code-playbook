#!/bin/bash
# Hook: PostToolUse → EnterPlanMode
# Records that planning is active for this session (marker file).
# Board updates and branch checks are handled by pre-enter-plan.sh (PreToolUse).
set -uo pipefail

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')

MARKER_DIR="/tmp/claude-plan-sessions"
mkdir -p "$MARKER_DIR"
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ)" > "${MARKER_DIR}/${SESSION_ID}.planning"

echo "Plan mode entered — session ${SESSION_ID}" >&2
exit 0
