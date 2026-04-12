#!/usr/bin/env bash
# Install ogham-mcp via uv, write its config, and enable FlashRank reranking.

set -euo pipefail

INSTALL_PATH="${INSTALL_PATH:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
. "${INSTALL_PATH}/functions/autoload.sh"

# ── Install binary ─────────────────────────────────────────────────────────────
header "Ogham MCP"

if ! command -v ogham &>/dev/null; then
  step "Installing ogham-mcp via uv..."
  uv tool install ogham-mcp
  export PATH="$HOME/.local/bin:$PATH"
  log "Ogham installed"
else
  skip "Ogham ($(ogham --version 2>/dev/null || echo 'installed'))"
fi

# ── Write config ───────────────────────────────────────────────────────────────
: "${POSTGRES_PASSWORD:?POSTGRES_PASSWORD is required}"
: "${OGHAM_PROFILE:?OGHAM_PROFILE is required}"
STATE_DIR="${STATE_DIR:-$HOME/.config/ogham}"

sed \
  -e "s/{{POSTGRES_PASSWORD}}/${POSTGRES_PASSWORD}/g" \
  -e "s/{{OGHAM_PROFILE}}/${OGHAM_PROFILE}/g" \
  "${SCRIPT_DIR}/config.toml.tmpl" > "${STATE_DIR}/config.toml"
log "Ogham config written → ${STATE_DIR}/config.toml"

if ogham health &>/dev/null 2>&1; then
  log "Ogham ↔ Postgres: connected"
else
  warn "Ogham health check failed — Postgres may still be warming up. Run 'ogham health' to verify."
fi

step "Activating profile: ${OGHAM_PROFILE}"
ogham use "${OGHAM_PROFILE}" 2>/dev/null || true
log "Profile: ${OGHAM_PROFILE}"

# ── Enable FlashRank reranking ─────────────────────────────────────────────────
if state.done "ogham_rerank_installed"; then
  skip "Ogham reranking (already installed)"
else
  step "Installing ogham-mcp[rerank] (FlashRank cross-encoder)..."
  if command -v uv &>/dev/null; then
    uv tool install "ogham-mcp[rerank]" 2>/dev/null \
      || uv tool upgrade ogham-mcp --extra rerank 2>/dev/null \
      || warn "Could not install rerank extra — try: uv tool install 'ogham-mcp[rerank]'"
  else
    pip install "ogham-mcp[rerank]" --break-system-packages 2>/dev/null \
      || warn "Could not install rerank extra"
  fi

  CONFIG_FILE="$HOME/.config/opencode/opencode.json"
  if [[ -f "${CONFIG_FILE}" ]]; then
    python3 - "${CONFIG_FILE}" <<'PYEOF'
import json, sys
path = sys.argv[1]
with open(path) as f:
    d = json.load(f)
env = d.get('mcp', {}).get('ogham', {}).get('environment', {})
env['RERANK_ENABLED'] = 'true'
env['RERANK_ALPHA'] = '0.55'
d['mcp']['ogham']['environment'] = env
with open(path, 'w') as f:
    json.dump(d, f, indent=2)
print("  \033[32m✔\033[0m  Reranking env vars added to opencode.json")
PYEOF
  fi

  state.mark "ogham_rerank_installed"
  log "FlashRank reranking enabled (RERANK_ALPHA=0.55)"
  info "Cross-encoder adds ~300ms per search. Improves MRR by ~8pp."
fi
