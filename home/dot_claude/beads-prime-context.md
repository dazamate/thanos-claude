# Beads Issue Tracker Active

Use `bd` for task tracking in this repo. The database lives in `.beads/`.

## Core rules

- Create a bead before starting work, and claim it with `bd update <id> --claim`.
- Find unblocked work with `bd ready --json`; read detail with `bd show <id> --json`.
- Link work discovered mid-task with `--deps discovered-from:<id>`.
- Do not use TodoWrite, TaskCreate, or markdown TODO lists for task tracking.
- `bd remember "fact"` stores durable project facts that sync with the repo. Per-user preferences belong in Claude's native memory, not here or in `CLAUDE.md`.
- Close finished work with `bd close <id> --reason "..."`.
- If a Dolt sync remote is configured, run `bd dolt push` before ending a session, and `bd dolt pull` before starting on another machine. In a workspace without one, `bd dolt push` fails and suggests `--yes`; do not use it, since that publishes the issue history.

## Commands

`bd ready`, `bd create "title" -p 1 -t bug --json`, `bd update <id> --claim`, `bd dep add <child> <parent>`, `bd show <id>`, `bd close <id>`, `bd remember`, `bd memories`.
