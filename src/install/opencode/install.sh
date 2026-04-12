#!/usr/bin/env bash
# Install opencode (AI coding agent) and write a base ~/.config/opencode/opencode.json
# if one does not already exist.
#
# The base config is a minimal shell — no MCP servers.
# Each tool's install script adds its own MCP block via opencode.upsert_mcp.

set -euo pipefail

INSTALL_PATH="${INSTALL_PATH:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
. "${INSTALL_PATH}/functions/autoload.sh"

# ── Install binary ─────────────────────────────────────────────────────────────
header "opencode"

if ! command -v opencode &>/dev/null; then
  step "Installing opencode..."
  if command -v npm &>/dev/null; then
    npm install -g opencode-ai
    export PATH="$(npm root -g)/.bin:$PATH"
    log "opencode installed via npm"
  else
    error "Node.js / npm not found — cannot install opencode. Run nodejs/install.sh first."
  fi
else
  skip "opencode ($(opencode --version 2>/dev/null || echo 'installed'))"
fi

# ── Write base config if missing ───────────────────────────────────────────────
CONFIG_DIR="$HOME/.config/opencode"
CONFIG_FILE="${CONFIG_DIR}/opencode.json"
mkdir -p "${CONFIG_DIR}"

if [[ -f "${CONFIG_FILE}" ]]; then
  skip "opencode.json (already exists)"
else
  cp "${SCRIPT_DIR}/opencode.dist.jsonc" "${CONFIG_FILE}"
  log "opencode.json created → ${CONFIG_FILE}"
  info "Tool install scripts will register their MCP servers into this file."
fi
