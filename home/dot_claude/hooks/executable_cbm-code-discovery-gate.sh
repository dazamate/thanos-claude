#!/usr/bin/env bash
# PreToolUse(Grep|Glob|Bash): send a session's code discovery through codebase-memory-mcp.
# The first text search of a session (the Grep or Glob tool, or grep/rg/find in Bash,
# which replace those tools in Claude Code's native build) is blocked with a nudge to
# use CBM. Later searches pass, because a CBM tool has run (see cbm-mcp-marker.sh) or
# the nudge was seen once.
# Adapted from sgaabdu4/claude-code-tips (MIT); state is keyed by session_id.
input=$(cat)

# Until CBM is installed (a machine mid-setup), stay out of the way.
[ -x "$HOME/.local/bin/codebase-memory-mcp" ] || exit 0

sid=$(jq -r '.session_id // empty' <<<"$input" 2>/dev/null)
[ -n "$sid" ] || exit 0
gate=/tmp/cbm-code-discovery-gate-$sid
marker=/tmp/cbm-mcp-used-$sid
if [ -e "$marker" ] || [ -e "$gate" ]; then
  exit 0
fi

# In Bash, only a command that starts with a search counts, not `... | grep x`.
if [ "$(jq -r '.tool_name' <<<"$input")" = Bash ]; then
  cmd=$(jq -r '.tool_input.command // ""' <<<"$input")
  search_re='(^|&&|\|\||;)[[:space:]]*(rtk[[:space:]]+)?(grep|rg|find)([[:space:]]|$)'
  [[ $cmd =~ $search_re ]] || exit 0
fi

# Subagents whose tool list has no MCP access can't follow the nudge.
case "$(jq -r '.agent_type // empty' <<<"$input")" in
  claude-code-guide) exit 0 ;;
esac

# CBM indexes git repos; anywhere else there's no graph to ask.
cwd=$(jq -r '.cwd // empty' <<<"$input")
git -C "${cwd:-.}" rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

touch "$gate"
cat >&2 <<'EOF'
BLOCKED: For code discovery, use codebase-memory-mcp tools first: search_graph(name_pattern) to find functions/classes, trace_path() for call chains, get_code_snippet(qualified_name) to read source. They are the mcp__codebase-memory-mcp__* tools; load their schemas with ToolSearch if they are deferred. If the graph is not indexed yet, call index_repository first. Fall back to text search (grep/find, or the Grep/Glob tools) only for text content. If you need it, retry.
EOF
exit 2
