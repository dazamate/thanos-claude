#!/usr/bin/env bash
# PreToolUse(Bash): RTK's command rewrite (`git status` -> `rtk git status`), without
# its auto-approval. RTK answers "allow" for every command your allow rules cover, but
# auto mode drops broad rules like Bash(*) so its classifier can review each command;
# removing the decision leaves that review in place. Registering RTK through this
# script instead of `rtk hook claude` is why RTK's config turns off its hook warning.
rtk=$(command -v rtk || echo "$HOME/.local/bin/rtk")
[ -x "$rtk" ] || exit 0
out=$("$rtk" hook claude) || exit 0
[ -n "$out" ] || exit 0
jq -c 'del(.hookSpecificOutput.permissionDecision, .hookSpecificOutput.permissionDecisionReason)' <<<"$out" 2>/dev/null || true
