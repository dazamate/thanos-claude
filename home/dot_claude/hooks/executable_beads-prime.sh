#!/usr/bin/env bash
# SessionStart(startup|resume|clear|compact): inject beads workflow context and
# project memories in repos that use beads. The text comes from this repo's
# managed file, and only memories come from bd: upstream `bd prime` also echoes
# a repo-controlled .beads/PRIME.md, which would let an untrusted checkout
# inject model instructions outside Claude Code's project trust gate.
cat >/dev/null

bd="$HOME/.local/bin/bd"
[ -x "$bd" ] || exit 0

# bd discovers .beads/ upward; check the same way first so repos without a
# workspace don't pay a process spawn at every session start. Require a file
# bd writes in a workspace: ~/.beads also exists for metrics, without these.
is_workspace() {
  [ -f "$1/config.yaml" ] || [ -f "$1/metadata.json" ] || [ -f "$1/redirect" ]
}
dir=$PWD
found=""
while :; do
  if [ -d "$dir/.beads" ] && is_workspace "$dir/.beads"; then found=1; break; fi
  [ "$dir" = "/" ] && break
  dir=$(dirname "$dir")
done
if [ -n "${BEADS_DIR:-}" ] && is_workspace "$BEADS_DIR"; then found=1; fi
[ -n "$found" ] || exit 0

context="$HOME/.claude/beads-prime-context.md"
[ -r "$context" ] && printf '%s\n' "$(<"$context")"

# Caps keep the injected memory section bounded. A short timeout bounds the
# SessionStart stall if another bd process holds the embedded single writer.
memories=$(BEADS_PRIME_TIMEOUT=2s "$bd" prime --memories-only \
  --max-memories 30 --max-memory-chars 8000 2>/dev/null || true)
case "$memories" in
  *"No memories stored."*) ;;
  *) [ -n "$memories" ] && printf '%s\n' "$memories" ;;
esac
