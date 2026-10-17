#!/bin/sh
# Adds a block to the end of this shell rc file that loads thanos-claude's shell
# functions, or updates the block where it is. The rest of the file is left as is.
set -eu
BLOCK='# >>> thanos-claude >>>
# Loads the `claude` wrapper (Headroom). Managed by chezmoi from thanos-claude.
if [ -f "$HOME/.config/thanos-claude/shell.sh" ]; then . "$HOME/.config/thanos-claude/shell.sh"; fi
# <<< thanos-claude <<<' awk '
  $0 == "# >>> thanos-claude >>>" { print ENVIRON["BLOCK"]; skip = 1; found = 1; next }
  skip { if ($0 == "# <<< thanos-claude <<<") skip = 0; next }
  { print }
  END { if (!found) { if (NR) print ""; print ENVIRON["BLOCK"] } }'
