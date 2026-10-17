# thanos-claude

My Claude Code setup as code, managed with [chezmoi](https://www.chezmoi.io). One command puts a machine into this state; `chezmoi diff` shows any drift from it.

This repo is generic. Anything specific to my own projects lives in a separate private overlay (see [Private overlay](#private-overlay)), so you can use this as-is or fork it.

## What's included

| Name | Kind | What it does |
|---|---|---|
| Claude Code | CLI | The coding agent itself, installed with the official native installer. |
| chezmoi | CLI | Applies this repo to the machine and shows drift from it. |
| [codebase-memory-mcp](https://github.com/DeusData/codebase-memory-mcp) | MCP server | Indexes each git repo into a code graph, so Claude can answer "who calls this?" or "where is X?" without reading whole files. Auto-indexes repos you open. |
| [chromiumfish-web](https://github.com/dazamate/chromium-fish-mcp) | MCP server | Web search and page fetching through a stealth Chromium browser. The default web tool. |
| [transcribe-youtube-mcp](https://github.com/dazamate/transcribe-youtube-mcp) | MCP server | Fetches YouTube video transcripts. Installed, but not registered: add it where you want it with `claude mcp add` or the overlay. |
| prefer-chromiumfish-web | Hook | Blocks the built-in WebSearch and WebFetch and points Claude to chromiumfish instead. Stays out of the way until chromiumfish is installed, and for the `claude-code-guide` subagent, which can't use MCP tools. |
| cbm-code-discovery-gate, cbm-mcp-marker | Hooks | Block the first text search of a session (grep/find in Bash, or the Grep/Glob tools) with a nudge to use codebase-memory-mcp. Once a CBM tool has run, or the nudge was seen once, searches pass. Only in git repos. |
| cbm-session-reminder | Hook | Adds CBM's "code discovery protocol" to the context at startup, resume, `/clear` and compaction. |
| bash-ban-raw-tools | Hook | Blocks `cat`, `head`, `tail` and `wc` in Bash and points Claude to the Read tool. Touching the unlock file named in the message lifts it for 10 minutes. |
| test-runner-nudge | Hook | The first time a session runs a whole test suite (`go test ./...`, `pytest`, `npm test`, `flutter test` and so on), suggests context-mode's `ctx_batch_execute`. Never blocks. |
| rtk-rewrite | Hook | Runs RTK's rewrite (`git status` becomes `rtk git status`), with RTK's auto-approval removed. |
| `CLAUDE.md`, `RTK.md` | Instructions | Global instructions loaded in every session: use chromiumfish for web access, CBM before text search, Read instead of `cat`; `RTK.md` explains RTK's condensed output. |
| [context-mode](https://github.com/mksglu/context-mode) | Plugin | Runs commands in a sandbox and indexes their output, so only matching sections enter the context (`ctx_batch_execute`, `ctx_execute`, `ctx_search`). Registers its own hooks. Pinned to a release tag. |
| [RTK](https://github.com/rtk-ai/rtk) | CLI | Condenses common command output (git, tests, package managers) before Claude sees it. The Apache-2.0 "oss" build, with telemetry declined. |
| expo | Plugin | Expo and React Native skills (routing, native UI, EAS builds and updates) plus the Expo MCP server. |
| gopls-lsp | Plugin | Go code intelligence (definitions, references, diagnostics) through gopls. |
| [find-skills](https://github.com/vercel-labs/skills) | Skill | Helps find and install agent skills for a task. |
| [frontend-design](https://github.com/anthropics/skills) | Skill | Design guidance for building distinctive, non-generic UI. |
| [playwright-bot-bypass](https://github.com/greekr4/playwright-bot-bypass) | Skill | Browser automation that avoids bot detection, using rebrowser-playwright. |
| [codeburn](https://github.com/getagentseal/codeburn) | CLI | Token and cost dashboard built from Claude Code session logs (`codeburn overview`). |
| gopls | CLI | Go language server used by the gopls-lsp plugin. Installed only if Go is present. |
| uv | CLI | Python package and project manager. Runs transcribe-youtube-mcp. |
| Node.js (via nvm) | Runtime | Runs codeburn, plugin hooks and the playwright skill. |
| git, curl, jq, python3 | System packages | Basics the scripts, the hook and the config edits rely on. |

The three skills are installed from their upstream repos at pinned commits, under their own licenses; this repo doesn't copy them.

### Where the hooks come from

The CBM, `bash-ban-raw-tools` and test-runner hooks are adapted from [sgaabdu4/claude-code-tips](https://github.com/sgaabdu4/claude-code-tips) (MIT, see [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md)), the companion repo to an article on cutting Claude Code's token use. They differ from the originals in these ways:

- **State is keyed by the session ID** Claude Code passes to hooks, not by `$PPID`.
- **Searches in Bash count.** Claude Code's native build (seen on 2.1.302) has no Grep or Glob tools: `grep`, `rg` and `find` in Bash are its built-in search (ugrep and bfs, which skip gitignored files). So the gate watches Bash as well as Grep and Glob, and `grep`/`rg`/`find` are neither blocked nor rewritten. `rtk grep` runs plain grep, which also searches `.venv` and `node_modules`.
- **No `| head` / `| tail` rule.** The original blocked `grep … | head`, but the trim happens before Claude sees the output.
- **Read isn't gated.** CBM's own guidance is to read files freely and to read before editing.
- **The unlock check works on Linux.** The original ran BSD `stat` first, which fails there.
- **RTK's auto-approve is removed.** RTK returns "allow" for any command your allow rules cover. Auto mode drops broad rules like `Bash(*)` so its classifier can review each command, and passing RTK's "allow" through could skip that review. RTK is registered through `rtk-rewrite.sh`, which keeps the rewrite and drops the decision, so RTK's "hook not found" warning is turned off in its config.
- **The reminder is registered once.** The original registered it twice, so it was injected twice.
- **Not ported:**
  - `memory-repo-symlink`: it moves project memory into each repo, where it could get committed.
  - The Copilot and e2e-runner sync hooks: they need VS Code Copilot and agents this repo doesn't ship.

### Things to know about context-mode

- It's licensed under Elastic-2.0.
- It adds about 1,200 tokens of routing instructions at session start.
- It checks npm for updates.
- It blocks WebFetch and most `curl`/`wget` calls, pointing Claude at its own fetch tools. `CLAUDE.md` keeps chromiumfish as the web tool.
- Each time its server starts, it adds a cache-repair hook and its `enabledPlugins` entry to `settings.json` if they're missing. Both are already in the settings template, so it finds nothing to change.

Key settings in `settings.json`:

| Setting | Value | What it does |
|---|---|---|
| `model` | `opus[1m]` | Opus with the 1M-token context window as the main model. |
| `effortLevel` / `modelSettings` | `high`, `xhigh` for Opus, Fable and DeepSeek | How much reasoning the model does per turn. |
| `advisorModel` | `opus` | Model used for the built-in advisor's second opinions. |
| `CLAUDE_CODE_SUBAGENT_MODEL` | `sonnet` | Runs subagents on Sonnet, which costs less than Opus. |
| `permissions.allow` | `Bash(*)`, `Read(*)` | Shell commands and file reads run without prompting. |
| `skipDangerousModePermissionPrompt` | `true` | Skips the confirmation when entering bypass-permissions mode. |

**Using this yourself:** fork it and review `home/.chezmoitemplates/settings.json` first. The permissions above suit me, not necessarily you.

## New machine

Needs `git` and `curl`. Linux, WSL and macOS (with Homebrew) are supported. Native Windows isn't yet.

```sh
git clone https://github.com/dazamate/thanos-claude.git ~/projects/thanos-claude
~/projects/thanos-claude/bootstrap.sh
claude   # log in
```

`bootstrap.sh` installs chezmoi and applies everything. chezmoi asks once for a private overlay repo; leave it blank if you don't have one. To answer without a prompt, run it as `THANOS_OVERLAY_REPO= ./bootstrap.sh`. It's safe to re-run.

## Private overlay

The overlay is an optional git repo for anything you don't want in this one: project-specific MCP servers, private notes in settings, your own skills. This repo only knows that an overlay may exist; its URL is kept in your local chezmoi config (`~/.config/chezmoi/chezmoi.toml`), never here.

| Overlay file | Merged into |
|---|---|
| `settings.json` | `~/.claude/settings.json`, deep-merged over this repo's settings. The overlay wins. |
| `mcp.json` → `mcpServers` | User-scope MCP servers in `~/.claude.json`, deep-merged (e.g. extra `env` for a server defined here). |
| `mcp.json` → `projects` | Project-scope MCP servers in `~/.claude.json`, keyed by project path. |
| `skills/<name>/` | Symlinked into `~/.claude/skills/<name>`. |

Paths starting with `~/` are expanded to your home directory. An example `mcp.json`:

```json
{
  "mcpServers": {
    "chromiumfish-web": { "env": { "CF_PERSONA_SEED": "my-persona" } }
  },
  "projects": {
    "~/projects/my-app": {
      "youtube-transcript": {
        "command": "uv",
        "args": ["--directory", "~/projects/transcribe-youtube-mcp", "run", "server.py"]
      }
    }
  }
}
```

Every `chezmoi apply` pulls the overlay before applying. To add one later, run `chezmoi init` and enter its URL.

## Day to day

| Task | Command |
|---|---|
| See what would change | `chezmoi diff` |
| Apply this repo to the machine | `chezmoi apply` |
| Start managing a new file | `chezmoi add ~/.claude/<file>` |
| Upgrade a tool or skill | Bump it in `home/.chezmoidata/packages.yaml`, then `chezmoi apply` |
| Add or change a user-scope MCP server | Edit `home/.chezmoitemplates/mcp-user.json`, then `chezmoi apply` |
| Change a setting | Edit `home/.chezmoitemplates/settings.json` (or the overlay's), then `chezmoi apply` |

Claude Code rewrites `~/.claude/settings.json` itself (e.g. via `/config`), so check `chezmoi diff` and copy any change you want to keep into the template. Close Claude Code before applying an MCP change, since it writes `~/.claude.json` while running. MCP servers are merged into what's already registered, so removing one here doesn't remove it from a machine; use `claude mcp remove` for that.

## Measuring the savings

codeburn works out token use and cost from the session logs Claude Code already keeps in `~/.claude/projects/`, so there's nothing to switch on. You can compare any stretch of time before you applied this repo with any stretch after. Claude Code deletes session logs after 30 days by default (the `cleanupPeriodDays` setting), so save a baseline if you'll compare later than that.

1. **Before you apply the repo, save a baseline.** If codeburn isn't installed yet, use `npx codeburn@0.9.27` in place of `codeburn`:

   ```sh
   codeburn overview -p 30days --provider claude > ~/codeburn-baseline.txt
   ```

2. **Work normally for a week or two.** Leave out the day you set things up, since it's mostly setup work.

3. **Compare a period before with a period after.** A is the reference period, B the one being measured:

   ```sh
   codeburn compare-periods --provider claude \
     --from-a 2026-10-01 --to-a 2026-10-14 \
     --from-b 2026-10-16 --to-b 2026-10-29 \
     | jq '{cost_per_100_calls: .normalized.per100Calls, change_pct: .totals.pct}'
   ```

   Cost per 100 API calls is the fairest number, because it doesn't depend on how much you worked. Totals go up and down with the amount of work.

Costs are what the tokens would cost at API rates. On a Claude subscription that's a measure of usage, not your bill. To see where the tokens go, run `codeburn optimize`, which points out waste, `codeburn context`, which shows what fills a session's context window, or `codeburn report` for the interactive dashboard.

Each layer can be removed on its own if the numbers don't justify it. Start with context-mode: it adds about 1,200 tokens to every session start, so it has to save more than that.

## Where things live

| What | Where in this repo |
|---|---|
| `settings.json` | `home/.chezmoitemplates/settings.json`, written by `home/dot_claude/modify_settings.json.tmpl` together with the overlay's settings |
| `CLAUDE.md`, `RTK.md`, hooks | `home/dot_claude/` |
| RTK's `config.toml` | `home/.chezmoitemplates/rtk-config.toml`, placed in `~/.config/rtk/` (Linux) or `~/Library/Application Support/rtk/` (macOS) |
| MCP servers in `~/.claude.json` | `home/.chezmoitemplates/mcp-user.json`, merged in by `home/modify_private_dot_claude.json.tmpl`. Only the `mcpServers` entries are touched; the rest of that file is Claude Code's own state and is never stored here. |
| Pinned tool versions, skills, plugins, source repos | `home/.chezmoidata/packages.yaml` |
| Install scripts | `home/.chezmoiscripts/` |

The install scripts run when their content changes, including when a pinned version they use changes. Every step checks before acting, so a re-run only installs what's missing or at the wrong version.

- **Base tools** (before files): git, curl, jq, python3 and venv, uv, Node.js via nvm, Claude Code.
- **Overlay** (before files, every apply, only if configured): clone or pull it, link its skills.
- **Claude tools** (after files): codebase-memory-mcp, RTK, codeburn, gopls (only if Go is installed), chromiumfish-web (clone, venv, browser), transcribe-youtube-mcp, plugins and their marketplaces (re-added when a pinned tag changes), skills, and the playwright skill's npm dependencies and Chromium.

`vendor/` holds the reviewed installers for chezmoi, codebase-memory-mcp and RTK. All three verify release checksums.

## Never stored here

Login credentials (`~/.claude/.credentials.json`), history, session transcripts, project memory, caches and plugin checkouts. `home/.chezmoiignore` lists them, so `chezmoi add` refuses them too.

## License

MIT, see [LICENSE](LICENSE). The skills and tools it installs keep their own licenses, and [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md) covers the material this repo includes from other projects.
