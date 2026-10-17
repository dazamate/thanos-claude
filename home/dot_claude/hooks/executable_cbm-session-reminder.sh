#!/usr/bin/env bash
# SessionStart(startup|resume|clear|compact): remind Claude to explore code through
# codebase-memory-mcp. SessionStart output is added to Claude's context.
# The text is CBM's own reminder (v0.12.1), as used in sgaabdu4/claude-code-tips (MIT).
cat >/dev/null

# Until CBM is installed (a machine mid-setup), stay out of the way.
[ -x "$HOME/.local/bin/codebase-memory-mcp" ] || exit 0

cat <<'EOF'
CRITICAL - Code Discovery Protocol:
1. ALWAYS use codebase-memory-mcp tools FIRST for ANY code exploration:
   - search_graph(name_pattern/label/qn_pattern) to find functions/classes/routes
   - trace_path(function_name, mode=calls|data_flow|cross_service) for call chains
   - get_code_snippet(qualified_name) for exact symbol source (precise ranges)
   - query_graph(query) for complex Cypher patterns
   - get_architecture(aspects) for project structure
   - search_code(pattern) for text search (graph-augmented grep)
   They are the mcp__codebase-memory-mcp__* tools; load their schemas with ToolSearch if they are deferred.
2. Fall back to Grep/Glob/Read ONLY for text content, config values and non-code files.
   Always Read a file before editing it.
3. If a project is not indexed yet, run index_repository FIRST.
EOF
