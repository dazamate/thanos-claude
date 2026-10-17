#!/usr/bin/env bash
# PreToolUse(Bash): block cat/head/tail/wc, which dump raw file content into the
# context, and point Claude at the Read tool instead. The block message names an
# unlock file to touch as an override; it expires 10 minutes after it was touched.
# Adapted from sgaabdu4/claude-code-tips (MIT). Differences: the unlock file is keyed
# by session_id; grep/rg/find aren't blocked, because in Claude Code's native build
# they are its built-in search (there are no Grep or Glob tools to send Claude to).
set -uo pipefail
# No `set -e`: on malformed input jq fails, and the hook must then allow (exit 0),
# not exit 1.

input=$(cat)
[ "$(jq -r '.tool_name // empty' <<<"$input" 2>/dev/null)" = Bash ] || exit 0
sid=$(jq -r '.session_id // empty' <<<"$input" 2>/dev/null)

unlock_all=/tmp/bash-raw-unlock
unlock_session=/tmp/bash-raw-unlock-${sid:-none}

unlocked() {
  local f=$1 mtime age
  [ -f "$f" ] || return 1
  # GNU stat first: on Linux, `stat -f` reports on the filesystem instead.
  mtime=$(stat -c %Y "$f" 2>/dev/null || stat -f %m "$f" 2>/dev/null || echo 0)
  age=$(( $(date +%s) - mtime ))
  # A future mtime (clock skew, touch -t) counts as expired, so it can't unlock forever.
  if [ "$age" -ge 0 ] && [ "$age" -lt 600 ]; then return 0; fi
  rm -f "$f"
  return 1
}
unlocked "$unlock_all" && exit 0
unlocked "$unlock_session" && exit 0

cmd=$(jq -r '.tool_input.command // ""' <<<"$input" 2>/dev/null)
first=$(awk 'NF { print $1; exit }' <<<"$cmd")
first=${first##*/}  # /bin/cat counts as cat

# Only the command's first word is checked, so chains like `cd x && cat y` pass.
case "$first" in
  cat|head|tail|wc) ;;
  *) exit 0 ;;  # includes `rtk ...`, which compresses the output itself
esac

override="Override (rare): touch $unlock_session for this session, or $unlock_all for all sessions. Either lasts 10 minutes."
case "$first" in
  cat|head|tail)
    echo "BLOCKED Bash '$first'. Use the Read tool (absolute path, optional offset/limit), or the Write tool to create a file. $override" >&2 ;;
  wc)
    echo "BLOCKED Bash 'wc'. To count lines, Read the file (line numbers are shown) or run 'rtk wc'. $override" >&2 ;;
esac
exit 2
