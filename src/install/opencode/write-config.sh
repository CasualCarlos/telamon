#!/usr/bin/env bash
# Write ~/.config/opencode/opencode.json with MCP server configuration.
# Idempotent: skips if all three MCP blocks (ogham, codebase-index, obsidian) are present.
# Refreshes the Obsidian API key on every run.
#
# Required env vars:
#   POSTGRES_PASSWORD  — Postgres password
#   OBSIDIAN_API_KEY   — Obsidian Local REST API key

set -euo pipefail

INSTALL_PATH="${INSTALL_PATH:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
. "${INSTALL_PATH}/functions/autoload.sh"

: "${POSTGRES_PASSWORD:?POSTGRES_PASSWORD is required}"
: "${OBSIDIAN_API_KEY:?OBSIDIAN_API_KEY is required}"

header "OpenCode Config"

CONFIG_DIR="$HOME/.config/opencode"
mkdir -p "${CONFIG_DIR}"
CONFIG_FILE="${CONFIG_DIR}/opencode.json"

# host.docker.internal works on both macOS and Linux (added to /etc/hosts on Linux)
OBS_HOST="host.docker.internal"

# Check if all MCP blocks are already present
if [[ -f "${CONFIG_FILE}" ]] && python3 -c "
import json, sys
d = json.load(open('${CONFIG_FILE}'))
mcp = d.get('mcp', {})
assert 'ogham' in mcp and 'obsidian' in mcp and 'codebase-index' in mcp
" 2>/dev/null; then
  skip "OpenCode MCP config (all servers present)"

  # Refresh Obsidian API key only if it changed
  python3 - "${CONFIG_FILE}" "${OBSIDIAN_API_KEY}" <<'PYEOF'
import json, sys
path, key = sys.argv[1], sys.argv[2]
with open(path) as f:
    d = json.load(f)
try:
    old = d['mcp']['obsidian']['environment'].get('API_KEY', '')
    if old != key:
        d['mcp']['obsidian']['environment']['API_KEY'] = key
        with open(path, 'w') as f:
            json.dump(d, f, indent=2)
        print("  \033[33m⚠\033[0m  Obsidian API key refreshed")
except Exception:
    pass
PYEOF
  exit 0
fi

[[ -f "${CONFIG_FILE}" ]] \
  && cp "${CONFIG_FILE}" "${CONFIG_FILE}.backup" \
  && warn "Backed up existing opencode.json → opencode.json.backup"

sed \
  -e "s/{{POSTGRES_PASSWORD}}/${POSTGRES_PASSWORD}/g" \
  -e "s/{{OBSIDIAN_API_KEY}}/${OBSIDIAN_API_KEY}/g" \
  -e "s/{{OBS_HOST}}/${OBS_HOST}/g" \
  "${SCRIPT_DIR}/opencode.json.tmpl" > "${CONFIG_FILE}"
log "OpenCode config written → ${CONFIG_FILE}"
