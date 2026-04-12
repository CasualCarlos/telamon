#!/usr/bin/env bash
# Set up Graphify in the current project: copy the OpenCode plugin JS and
# install git hooks.
#
# The plugin entry (".opencode/plugins/graphify.js") is already present in
# storage/opencode.jsonc (added by graphify/install.sh during `make up`).
# For projects with their own opencode config it flows in via merge-config.py
# in bin/init.sh. No separate opencode.json is written here.
#
# The graphify skill is shipped as a static file in src/skills/graphify/SKILL.md
# and is made available to projects via the .opencode/skills/adk symlink created
# by `make init`. No download or copying is needed.

set -euo pipefail

INSTALL_PATH="${INSTALL_PATH:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
. "${INSTALL_PATH}/functions/autoload.sh"

header "Graphify"

if ! command -v graphify &>/dev/null; then
  warn "graphify not found — skipping project setup"
  return 0 2>/dev/null || exit 0
fi

# ── Copy plugin JS into project ───────────────────────────────────────────────
PLUGIN_SRC="${SCRIPT_DIR}/graphify.js"
PLUGIN_DEST=".opencode/plugins/graphify.js"

mkdir -p ".opencode/plugins"
if [[ -f "${PLUGIN_DEST}" ]]; then
  skip "${PLUGIN_DEST} (already exists)"
else
  cp "${PLUGIN_SRC}" "${PLUGIN_DEST}"
  log "Copied graphify plugin → ${PLUGIN_DEST}"
fi

# ── Install git hooks ─────────────────────────────────────────────────────────
step "Installing graphify git hooks..."
graphify hook install 2>/dev/null || true
log "Graphify git hooks installed"

info "Run 'graphify .' to build the initial knowledge graph."
