#!/usr/bin/env bash
# Write repomix.config.json in the current project directory.
# Idempotent: skipped if the file already exists.

set -euo pipefail

INSTALL_PATH="${INSTALL_PATH:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
. "${INSTALL_PATH}/functions/autoload.sh"

header "Repomix Config"

REPOMIX_CONFIG="$(pwd)/repomix.config.json"

if [[ -f "${REPOMIX_CONFIG}" ]]; then
  skip "Repomix config (already exists)"; exit 0
fi

cp "${SCRIPT_DIR}/repomix.config.json" "${REPOMIX_CONFIG}"
log "Repomix config written → repomix.config.json"
