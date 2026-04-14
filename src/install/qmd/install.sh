#!/usr/bin/env bash
# Install QMD (Query Markup Documents — semantic search for Markdown vaults)
# via npm, and download the upstream QMD skill into
# src/skills/memory/qmd/SKILL.md so it is available to all initialized projects
# via the .opencode/skills/adk symlink.
#
# QMD stores a global index at ~/.cache/qmd/index.sqlite and supports multiple
# named collections in one index.  The initial collection registration and
# embedding happen in qmd/init-project.sh, not here.
#
# Models are auto-downloaded on first use (~2 GB total):
#   - 300 MB  embeddinggemma   (embedding)
#   - 640 MB  qwen3-reranker   (reranker)
#   - 1.1 GB  qmd-query-expansion (query expansion)

set -euo pipefail

INSTALL_PATH="${INSTALL_PATH:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
ADK_ROOT="${ADK_ROOT:-$(cd "${INSTALL_PATH}/../.." && pwd)}"
# shellcheck disable=SC1091
. "${INSTALL_PATH}/functions/autoload.sh"

# ── Install QMD binary ─────────────────────────────────────────────────────────
header "QMD (semantic vault search)"

if ! command -v qmd &>/dev/null; then
  step "Installing QMD via npm..."
  npm install -g @tobilu/qmd
  log "QMD installed"
else
  skip "QMD ($(qmd --version 2>/dev/null || echo 'installed'))"
fi

# ── Download QMD agent skill into src/skills/memory/qmd/ ──────────────────────
# The skill teaches agents to use QMD proactively before reading vault files,
# before creating notes (duplicate check), and after creating notes (find related).
# It reaches all initialized projects via the .opencode/skills/adk → src/skills
# symlink created by bin/init.sh.
SKILL_URL="https://raw.githubusercontent.com/tobi/obsidian-mind/main/.claude/skills/qmd/SKILL.md"
SKILL_DIR="${ADK_ROOT}/src/skills/memory/qmd"
SKILL_FILE="${SKILL_DIR}/SKILL.md"

step "Downloading QMD skill → src/skills/memory/qmd/SKILL.md ..."
mkdir -p "${SKILL_DIR}"
if curl -fsSL "${SKILL_URL}" -o "${SKILL_FILE}" 2>/dev/null; then
  log "QMD skill downloaded → src/skills/memory/qmd/SKILL.md"
else
  warn "QMD skill download failed — will use bundled ADK skill at ${SKILL_FILE}"
  warn "To retry manually: curl -fsSL ${SKILL_URL} -o ${SKILL_FILE}"
fi

info "Run 'make init PROJ=<path>' to register QMD collections for a project (initial embed can take a few minutes)."
