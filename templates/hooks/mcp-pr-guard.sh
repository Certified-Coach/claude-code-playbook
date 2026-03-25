#!/bin/bash
# Claude Code hook: fires before MCP GitHub create_pull_request tool.
# Ensures PRs target staging, not main.
#
# ADAPT: Change 'staging' to your integration branch name.

INPUT=$(cat 2>/dev/null) || true
BASE=$(printf '%s' "$INPUT" | jq -r '.tool_input.base // empty' 2>/dev/null) || true

# Block if targeting main
if [ "$BASE" = "main" ] || [ "$BASE" = "master" ]; then
  echo "BLOCKED: PRs must target staging, never main." >&2
  exit 2
fi

# Warn if base is not staging
if [ -n "$BASE" ] && [ "$BASE" != "staging" ]; then
  echo "WARNING: PR base is '$BASE' — expected 'staging'." >&2
fi

exit 0
