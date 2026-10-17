#!/bin/sh
# Set up a machine from this repo: install chezmoi, then apply everything.
#
#   gh auth login
#   gh repo clone dazamate/thanos-claude ~/projects/thanos-claude
#   ~/projects/thanos-claude/bootstrap.sh
#
# Safe to re-run.
set -eu

repo_dir=$(cd "$(dirname "$0")" && pwd)
chezmoi_version=v2.73.1
export PATH="$HOME/.local/bin:$PATH"

if command -v chezmoi >/dev/null 2>&1; then
  echo "==> chezmoi already installed: $(chezmoi --version | cut -d, -f1)"
else
  echo "==> installing chezmoi $chezmoi_version"
  sh "$repo_dir/vendor/chezmoi-install.sh" -b "$HOME/.local/bin" -t "$chezmoi_version"
fi

# A private overlay repo needs credentials; let git use the gh login if there is one.
if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
  gh auth setup-git
fi

# chezmoi asks for an optional private overlay repo. To answer without a prompt,
# set THANOS_OVERLAY_REPO (empty for none).
if [ -n "${THANOS_OVERLAY_REPO+set}" ]; then
  set -- --promptString "Private overlay repo URL (blank for none)=$THANOS_OVERLAY_REPO"
fi
chezmoi init --source "$repo_dir" --apply "$@"
echo "==> done. Run 'claude' and log in if this is a new machine."
