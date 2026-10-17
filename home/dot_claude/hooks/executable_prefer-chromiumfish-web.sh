#!/usr/bin/env bash
# PreToolUse(WebSearch|WebFetch): route web access through the chromiumfish-web MCP server.
input=$(cat)

# Until chromiumfish is installed (a machine mid-setup), keep the built-ins.
[ -x "$HOME/.claude/chromiumfish/venv/bin/python" ] || exit 0

# Subagents whose tool list has no MCP access keep the built-ins.
agent=$(jq -r '.agent_type // empty' <<<"$input")
case "$agent" in
  claude-code-guide) exit 0 ;;
esac

tool=$(jq -r '.tool_name' <<<"$input")
case "$tool" in
  WebSearch) alt=mcp__chromiumfish-web__websearch ;;
  *) alt=mcp__chromiumfish-web__webfetch ;;
esac

jq -n --arg tool "$tool" --arg alt "$alt" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "deny",
    permissionDecisionReason: "\($tool) is disabled on this machine. Use \($alt) instead (load its schema with ToolSearch if it is deferred)."
  }
}'
