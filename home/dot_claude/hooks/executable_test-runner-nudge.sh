#!/usr/bin/env bash
# PreToolUse(Bash): when a whole test suite or analyzer run starts, suggest context-mode's
# ctx_batch_execute, which keeps the output in its sandbox and returns only what matches.
# A nudge, not a block, given once per session. Scoped runs (one file, -run, -k) pass quietly.
# Based on flutter-ctx-redirect from sgaabdu4/claude-code-tips (MIT), widened to other runners.
input=$(cat)

# The nudge points at context-mode; without it there's nothing to suggest.
[ -d "$HOME/.claude/plugins/cache/context-mode" ] || exit 0

sid=$(jq -r '.session_id // empty' <<<"$input" 2>/dev/null)
[ -n "$sid" ] || exit 0
flag=/tmp/test-runner-nudge-$sid
[ -e "$flag" ] && exit 0

cmd=$(jq -r '.tool_input.command // ""' <<<"$input")
runner_re='(^|[;&|[:space:]])(go test|pytest|python3? -m pytest|(npm|pnpm|yarn|bun)( run)? test|npx (jest|vitest)|jest|vitest|cargo test|flutter (test|analyze)|dart test)([[:space:]]|$)'
# Scoped: a test filter flag, a single test file, or output sent to a file (not 2>&1).
scoped_re='(^|[[:space:]])(-run|-k|-t|--testNamePattern|--plain-name|--name)([[:space:]=]|$)|::|_test\.go|\.py([[:space:]]|$)|\.dart|\.(test|spec)\.|(^|[^0-9&])>[[:space:]]*[^&[:space:]]'
[[ $cmd =~ $runner_re ]] || exit 0
runner=${BASH_REMATCH[2]}
[[ $cmd =~ $scoped_re ]] && exit 0

touch "$flag"
jq -n --arg runner "$runner" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    additionalContext: "Note: a full `\($runner)` run can print thousands of lines. For runs like this, consider mcp__plugin_context-mode_context-mode__ctx_batch_execute (load its schema with ToolSearch if it is deferred): it runs the command in a sandbox, indexes the output and returns only the sections that match your queries, such as \"FAIL\" or \"error\". This command runs as is."
  }
}'
