#!/bin/bash
# Hook: PreToolUse → EnterPlanMode
# Pre-flight check with auto-remediation before entering plan mode.
#
# Checks:
#   1. Must not be on staging/main — need an issue branch
#   2. If issue not on project board, add it (if board configured)
#   3. Move issue to In Progress (if board configured)
#
# This hook can BLOCK plan entry if it cannot determine the issue.
#
# ADAPT: Replace the PROJECT_ID, FIELD_ID, and IN_PROGRESS_ID values
# below with your project board's GraphQL IDs. The setup script fills
# these in automatically. If you don't use a project board, leave them
# empty — the hook still works (just skips board automation).
#
# To find your IDs manually:
#   gh project field-list <PROJECT_NUMBER> --owner <OWNER> --format json
set -uo pipefail

INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd // "."')
cd "$CWD" 2>/dev/null || true

BRANCH=$(git branch --show-current 2>/dev/null || echo "")
ISSUE_NUMBER=$(echo "$BRANCH" | grep -oE '^[0-9]+' || echo "")

# ── Board automation config (filled by setup) ─────────────
# Leave empty if not using a GitHub Project board.
PROJECT_ID="{{PROJECT_ID}}"
FIELD_ID="{{STATUS_FIELD_ID}}"
IN_PROGRESS_ID="{{IN_PROGRESS_ID}}"
GITHUB_OWNER="{{GITHUB_OWNER}}"
GITHUB_REPO="{{GITHUB_REPO}}"

# ── If on an issue branch, proceed with board updates ─────
if [ -n "$ISSUE_NUMBER" ]; then

  # Skip board automation if not configured
  if [ -z "$PROJECT_ID" ] || [ "$PROJECT_ID" = "{{PROJECT_ID}}" ]; then
    echo "Pre-flight OK: branch ${BRANCH}, issue #${ISSUE_NUMBER} (no board configured)" >&2
    exit 0
  fi

  # Query issue for its project item
  BOARD_DATA=$(gh api graphql -f query='query($owner: String!, $repo: String!, $issue: Int!) {
    repository(owner: $owner, name: $repo) {
      issue(number: $issue) {
        projectItems(first: 10) {
          nodes {
            id
            project { id }
            fieldValues(first: 10) {
              nodes {
                ... on ProjectV2ItemFieldSingleSelectValue { name }
              }
            }
          }
        }
      }
    }
  }' -f owner="$GITHUB_OWNER" -f repo="$GITHUB_REPO" -F issue="$ISSUE_NUMBER" 2>/dev/null || echo "")

  ITEM_ID=$(echo "$BOARD_DATA" | jq -r ".data.repository.issue.projectItems.nodes[] | select(.project.id == \"${PROJECT_ID}\") | .id" 2>/dev/null || echo "")

  if [ -z "$ITEM_ID" ]; then
    # Add to board
    PROJECT_NUMBER=$(gh project list --owner "$GITHUB_OWNER" --format json --jq ".projects[] | select(.id == \"${PROJECT_ID}\") | .number" 2>/dev/null || echo "")
    if [ -n "$PROJECT_NUMBER" ]; then
      gh project item-add "$PROJECT_NUMBER" --owner "$GITHUB_OWNER" \
        --url "https://github.com/${GITHUB_OWNER}/${GITHUB_REPO}/issues/${ISSUE_NUMBER}" 2>/dev/null || true
      echo "Added issue #${ISSUE_NUMBER} to project board." >&2
    fi

    # Re-fetch item ID
    BOARD_DATA=$(gh api graphql -f query='query($owner: String!, $repo: String!, $issue: Int!) {
      repository(owner: $owner, name: $repo) {
        issue(number: $issue) {
          projectItems(first: 10) {
            nodes { id project { id } }
          }
        }
      }
    }' -f owner="$GITHUB_OWNER" -f repo="$GITHUB_REPO" -F issue="$ISSUE_NUMBER" 2>/dev/null || echo "")
    ITEM_ID=$(echo "$BOARD_DATA" | jq -r ".data.repository.issue.projectItems.nodes[] | select(.project.id == \"${PROJECT_ID}\") | .id" 2>/dev/null || echo "")
  fi

  # Move to In Progress (if not already forward)
  if [ -n "$ITEM_ID" ]; then
    CURRENT_STATUS=$(echo "$BOARD_DATA" | jq -r ".data.repository.issue.projectItems.nodes[] | select(.project.id == \"${PROJECT_ID}\") | .fieldValues.nodes[] | select(.name != null) | .name" 2>/dev/null || echo "")

    case "$CURRENT_STATUS" in
      "In Progress"|"In Review"|"Done")
        echo "Issue #${ISSUE_NUMBER} is '${CURRENT_STATUS}' — not moving backward." >&2
        ;;
      *)
        gh api graphql -f query="mutation {
          updateProjectV2ItemFieldValue(input: {
            projectId: \"${PROJECT_ID}\"
            itemId: \"${ITEM_ID}\"
            fieldId: \"${FIELD_ID}\"
            value: { singleSelectOptionId: \"${IN_PROGRESS_ID}\" }
          }) { projectV2Item { id } }
        }" 2>/dev/null && echo "Issue #${ISSUE_NUMBER} → In Progress" >&2 || true
        ;;
    esac
  fi

  echo "Pre-flight OK: branch ${BRANCH}, issue #${ISSUE_NUMBER}" >&2
  exit 0
fi

# ── No issue branch — need to create one ─────────────────
case "$BRANCH" in
  staging|main|"")
    cat >&2 <<'MSG'
╔══════════════════════════════════════════════════════════════╗
║  PLAN MODE BLOCKED — No issue branch detected               ║
║                                                              ║
║  You are on staging/main. Planning requires an issue branch. ║
║                                                              ║
║  To fix, run before entering plan mode:                      ║
║    1. Determine the issue number                             ║
║    2. git checkout -b <issue-number>-<description>           ║
║    3. Then enter plan mode again                             ║
║                                                              ║
║  Or ask Claude to create the branch for you.                 ║
╚══════════════════════════════════════════════════════════════╝
MSG
    echo '{"hookSpecificOutput": {"hookEventName": "PreToolUse", "decision": {"behavior": "block", "reason": "No issue branch. Create a branch (e.g. git checkout -b 42-fix-description) before entering plan mode."}}}'
    exit 0
    ;;
  *)
    echo "Warning: branch '${BRANCH}' does not start with an issue number. Board automation will not work." >&2
    exit 0
    ;;
esac
