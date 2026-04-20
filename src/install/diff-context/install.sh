#!/usr/bin/env bash
set -euo pipefail

INSTALL_PATH="${INSTALL_PATH:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
# shellcheck disable=SC1091
. "${INSTALL_PATH}/functions/autoload.sh"

header "Diff Context"

opencode.upsert_plugin ".opencode/plugins/telamon/diff-context.js"
