#!/usr/bin/env bash
# PostToolUse(mcp__codebase-memory-mcp__.*): record that CBM was used this session,
# so cbm-code-discovery-gate.sh lets Grep and Glob through from now on.
# Adapted from sgaabdu4/claude-code-tips (MIT); state is keyed by session_id.
sid=$(jq -r '.session_id // empty' 2>/dev/null)
[ -n "$sid" ] && touch "/tmp/cbm-mcp-used-$sid"
exit 0
