# Web access

Use `mcp__chromiumfish-web__websearch` for web searches and `mcp__chromiumfish-web__webfetch` for fetching URLs, also where context-mode suggests `ctx_fetch_and_index`. The built-in WebSearch and WebFetch are blocked by a hook.

# Code discovery

Find code with the codebase-memory-mcp tools (`search_graph`, `trace_path`, `get_code_snippet`) before searching text with grep or find. A hook blocks the first text search of a session until one of them has run.

# Shell

`cat`, `head`, `tail` and `wc` are blocked in Bash by a hook: read files with the Read tool. Run commands with long output, such as a full test suite, through context-mode's `ctx_batch_execute`.

@RTK.md
