# Shared helpers for the install scripts.
export PATH="$HOME/.local/bin:$HOME/go/bin:$HOME/.local/go/bin:/usr/local/go/bin:$PATH"
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
# Never let git stop and ask for credentials; a failed clone is reported instead.
export GIT_TERMINAL_PROMPT=0

log()  { printf '==> %s\n' "$*"; }
ok()   { printf '    ok: %s\n' "$*"; }
warn() { printf 'WARN: %s\n' "$*" >&2; }
have() { command -v "$1" >/dev/null 2>&1; }
sha256() { if have sha256sum; then sha256sum "$1"; else shasum -a 256 "$1"; fi | cut -d' ' -f1; }

# nvm.sh breaks under `set -u` and can return non-zero with no default alias.
load_nvm() {
  if [ -s "$NVM_DIR/nvm.sh" ]; then
    set +u
    . "$NVM_DIR/nvm.sh" || true
    set -u
  fi
}
load_nvm
