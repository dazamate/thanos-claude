# Shell functions for Claude Code, loaded from ~/.bashrc and ~/.zshrc.

# Headroom without its usage beacon (on by default) or update check (versions are
# pinned in packages.yaml). Exported, so the proxy, `headroom` commands and the
# `headroom mcp serve` that every session starts all see them. settings.json sets
# them too, for sessions that aren't started from a shell.
export HEADROOM_BEACON=off HEADROOM_UPDATE_CHECK=off

# `claude` runs through Headroom, a local proxy that compresses each request before
# it goes to the API. `command claude` runs it directly, which Remote Control needs:
# it only works against api.anthropic.com.
claude() {
  # Headroom isn't installed yet, or the API is already pointed somewhere else
  # (another provider, or a session that is itself running through Headroom).
  if ! command -v headroom >/dev/null 2>&1 || [ -n "${ANTHROPIC_BASE_URL:-}" ]; then
    command claude "$@"
    return
  fi
  # Subcommands that don't talk to the model skip the proxy.
  case "${1:-}" in
    agents|attach|auth|auto-mode|doctor|gateway|import|install|logs|mcp|plugin|plugins|\
    purge|respawn|rm|setup-token|stop|kill|ultrareview|update|upgrade|-v|--version|-h|--help)
      command claude "$@"
      return
      ;;
  esac
  # No Serena code-memory server: codebase-memory-mcp does that job.
  # Not --1m: it forces an older Opus, and `opus[1m]` in settings.json already
  # keeps the 1M window through the proxy.
  HEADROOM_CODE_MEMORY=none command headroom wrap claude -- "$@"
}
