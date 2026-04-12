# MEMORY

Reusable decisions and discoveries across sessions. Add new entries at the top of each section.

---

## Shell / Bash

### `docker ps | grep` fails in pipefail subshells
**Date**: 2026-04-12
`docker ps | grep -q "container-name"` can silently fail in `set -euo pipefail` subshells when `docker ps` output has very long lines that get truncated by the pipe buffer.
**Fix**: always use `docker ps --format '{{.Names}}' | grep -q "^container-name$"` for exact name matching.

### Makefile evals shell expressions at parse time
**Date**: 2026-04-12
Lines like `IS_DOCKER := $(shell ./scripts/is-in-docker.sh)` are evaluated when `make` parses the Makefile, not when a target runs. A missing script causes an error on every `make` invocation, even for unrelated targets. Keep such helper scripts in version control even if trivial.

---

## Ogham

### `ogham health` fails with `SUPABASE_URL is required` after template fix
**Date**: 2026-04-12
If `~/.config/ogham/config.toml` was written with `DATABASE_BACKEND = "supabase"` (from a stale run before the template was corrected), `ogham health` fails validation even though Postgres is running fine. Self-heals when `make up` re-runs `ogham/install.sh` and overwrites the config. Not a code bug — a one-time machine-state issue.

### `ogham/config.toml.tmpl` must use `backend = "postgres"`
**Date**: 2026-04-12
The ogham installer template must set `[database] backend = "postgres"`. Using `"supabase"` requires a separate `SUPABASE_URL` env var and will break `ogham health` even with Postgres running.

---

## make / Makefile

### `docker compose up` must precede `run.sh` in `make up`
**Date**: 2026-04-12
The installer (`src/install/run.sh`) runs health checks (e.g. `ogham health`) that require the Postgres and Ollama containers to already be running. Always start `docker compose up -d` **before** calling `run.sh`.

---

## Installer / run.sh

### `--status` checks should use exact container name matching
**Date**: 2026-04-12
All container presence checks in the `--status` block must use `docker ps --format '{{.Names}}'` and anchor the grep pattern (`^name$`) to avoid false positives from partial name matches and false negatives from truncated output.

---

## opencode / JSONC config

### `storage/opencode.jsonc` contains `//` comments — never use `json.load`
**Date**: 2026-04-12
Any Python script that reads `storage/opencode.jsonc` must strip JSONC comments first. Use the inline `strip_jsonc_comments()` tokenizer (character-by-character parser handling strings, `//` line comments, `/* */` block comments). Both `opencode.upsert_mcp` and `opencode.set_mcp_env` in `functions/opencode.sh` already do this. Do not regress to `json.load`.

### `{file:path}` secret paths are relative to the project root
**Date**: 2026-04-12
opencode resolves `{file:...}` paths relative to the directory where `opencode.jsonc` lives. Since projects get a symlink `<proj>/opencode.jsonc → <adk-root>/storage/opencode.jsonc`, the secret path in the config must be `storage/secrets/<name>` (relative to the project root, not the ADK root).

---

## Obsidian MCP

### `obsidian-mcp` Docker service removed from compose
**Date**: 2026-04-12
The always-on `obsidian-mcp` compose service was removed because it crashes at startup when Obsidian is not running (tests the API URL on boot, exits 1 if unreachable). The MCP is registered in `opencode.jsonc` as an on-demand `docker run` command instead — no persistent service needed.

---

## cass

### `cass index` is extremely slow — do not run in installer
**Date**: 2026-04-12
`cass index` on a real codebase takes 13+ minutes. It must not be called from `install.sh`. It runs lazily on first `cass search`. Remove any `cass index` call from the installer.

---

## Storage layout

### All ADK output dirs live under `storage/`
**Date**: 2026-04-12
All runtime data, secrets, state, and cache must be under `storage/` in the ADK root:
- `storage/pgdata/` — Postgres data volume
- `storage/ollama/` — Ollama model cache
- `storage/secrets/` — one plain-text file per secret (git-ignored)
- `storage/state/` — installer state (`setup-inputs`, `.setup-state`)
- `storage/opencode.jsonc` — shared opencode config (tracked in git)
Legacy root-level `pgdata/` and `ollama/` dirs are obsolete.

### `.gitignore` pattern for `storage/`
**Date**: 2026-04-12
Correct pattern:
```
storage/*
!storage/.gitkeep
!storage/opencode.jsonc
```
`storage/secrets/` does **not** need a separate exclusion line because `storage/*` already ignores everything; the `!` exceptions whitelist only what should be tracked.
