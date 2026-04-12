#!/usr/bin/env bash
# Install cass (agent session history search) via Homebrew tap, then build its index.

set -euo pipefail

INSTALL_PATH="${INSTALL_PATH:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
# shellcheck disable=SC1091
. "${INSTALL_PATH}/functions/autoload.sh"

# ── Install binary ─────────────────────────────────────────────────────────────
header "cass (agent session search)"

if ! command -v cass &>/dev/null; then
  step "Installing cass via Homebrew..."
  brew tap dicklesworthstone/tap 2>/dev/null || true
  brew install dicklesworthstone/tap/cass
  log "cass installed"
else
  skip "cass ($(cass --version 2>/dev/null || echo 'installed'))"
fi

# ── Build initial index ────────────────────────────────────────────────────────
if state.done "cass_indexed"; then
  skip "cass initial index"
else
  if command -v cass &>/dev/null; then
    step "Building initial cass index..."
    cass index 2>/dev/null || true
    state.mark "cass_indexed"
    log "cass index built"
  else
    warn "cass not found — skipping index"
  fi
fi
