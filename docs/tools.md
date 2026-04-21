---
layout: page
title: Tools
description: Every tool Telamon installs and manages.
nav_section: docs
---

Every tool Telamon installs and manages — all local, all automatic.

## At a glance

| Tool | What it does | Priority |
|---|---|---|
| [Ogham MCP](#ogham-mcp--semantic-agent-memory) | Stores and recalls decisions, bugs, patterns by meaning | Tier 1 |
| [Graphify](#graphify--codebase-knowledge-graph) | Auto-built structural knowledge graph of the codebase | Tier 2 |
| [Codebase Index](#codebase-index--semantic-code-search) | Find code by natural language description | Tier 2 |
| [Repomix](#repomix--directory-context-packer) | Packs many files into a single compressed context dump | Tier 2 |
| [Obsidian MCP](#obsidian-mcp--curated-knowledge-vault) | Read/write bridge to a human-curated knowledge vault | Tier 3 |
| [QMD](#qmd--vault-semantic-search) | Semantic search over the Obsidian vault | Tier 3 |
| [Cass](#cass--agent-session-history-search) | Search past agent session transcripts | Tier 3 |
| [RTK](#rtk--token-compression-proxy) | Compresses bash output before it reaches the LLM | Tier 2 |
| [Caveman](#caveman--token-efficient-communication-mode) | Ultra-compressed communication (~75% token reduction) | Tier 2 |
| [promptfoo](#promptfoo--agent-evaluation-framework) | Automated quality checks for agent behavior | Tier 2 |
| [Session Capture](#session-capture--automatic-memory-promotion) | Auto-promotes learnings to memory before compaction | Built-in |
| [Diff Context](#diff-context--session-aware-git-change-summary) | Injects git change summary at session start | Built-in |
| [Langfuse](#langfuse--observability-optional) | LLM observability — token usage, latency, cost | Optional |
| [Graphiti](#graphiti--temporal-knowledge-graph-optional) | Temporal knowledge graph backed by Neo4j | Optional |

**Tier 1** = highest ROI, essential. **Tier 2** = high value, worth the (automatic) setup. **Tier 3** = useful, value depends on usage habits. **Optional** = enable when needed.

---

## Tool details

### Ogham MCP — Semantic Agent Memory

[ogham-mcp](https://github.com/ogham-mcp/ogham-mcp)

Stores and retrieves decisions, bugs, and patterns using semantic vector search.
Backed by a local **Postgres + pgvector** database and **Ollama** embeddings (`nomic-embed-text`).

- Persists knowledge across sessions and projects using named profiles
- Searches by meaning, not exact text
- FlashRank cross-encoder reranking improves result precision (~+8pp MRR)

**Agent commands (MCP tools):** `switch_profile`, `store_memory`, `hybrid_search`, `explore_knowledge`, `list_recent`, `find_related`

---

### Graphify — Codebase Knowledge Graph

[graphify](https://github.com/safishamsi/graphify)

Builds a structural knowledge graph of the codebase. Identifies god nodes, architectural layers, call relationships, and module boundaries.

- **Auto-build**: `telamon init` builds the graph. Existing graphs are skipped.
- **Scheduled updates**: platform-native timer runs `graphify . --update` every 30 minutes
- **MCP server**: tools include `query_graph`, `get_node`, `get_neighbors`, `get_community`, `god_nodes`, `graph_stats`, `shortest_path`
- **Context injection**: opencode plugin injects god nodes and communities into the first tool call of each session

Particularly valuable for large legacy codebases where nobody has a complete mental model.

**Manage scheduled updates:**
- Linux: `systemctl --user status graphify-update-<project-name>.timer`
- macOS: `launchctl list | grep graphify-update-<project-name>`

---

### Codebase Index — Semantic Code Search

[opencode-codebase-index](https://github.com/Helweg/opencode-codebase-index)

Indexes the project's source code using Ollama embeddings, enabling natural-language search.

- Ask naturally: *"find the authentication logic"*, *"where is the payment handler?"*
- Results ranked by semantic similarity
- Built once per project; a file watcher maintains it automatically

Complements Graphify: Graphify tells you the structure, codebase-index lets you find code by meaning.

---

### Repomix — Directory Context Packer

[repomix](https://github.com/yamadashy/repomix)

Packs directory contents into a single compressed context dump using Tree-sitter-aware chunking.
~70% token reduction compared to reading files individually.

- Replaces 5+ individual file reads with a single structured dump
- Language-aware chunking preserves code structure
- Security scanning detects secrets before context is sent to the model

Do **not** combine with codebase-index for the same files — redundant context wastes tokens.

---

### Obsidian MCP — Curated Knowledge Vault

[obsidian-mcp](https://github.com/oleksandrkucherenko/obsidian-mcp)

Bridges the agent to an Obsidian vault containing long-lived, human-curated knowledge.
Each project gets its own vault subfolder:

```
<project>/bootstrap/       ← always-on context (loaded like AGENTS.md)
<project>/brain/
  memories.md              ← categorized lessons learned
  key_decisions.md         ← architectural decisions with rationale
  patterns.md              ← established codebase conventions
  gotchas.md               ← traps, constraints, known issues
<project>/work/active/     ← in-progress work notes
<project>/work/archive/    ← completed work notes
<project>/reference/       ← architecture maps, flow docs
<project>/thinking/        ← scratchpad for drafts
```

High value if you maintain notes. If nobody writes docs it adds nothing.

> After install, the Obsidian *Local REST API* community plugin must be enabled manually — the installer walks you through the steps.

---

### QMD — Vault Semantic Search

[qmd](https://github.com/tobi/qmd)

Semantic search over the Obsidian vault using **fully local GGUF models** (~2 GB, auto-downloaded).

- One named collection per vault section: `<project>-brain`, `-work`, `-reference`, `-thinking`
- MCP server with `query`, `get`, `multi_get`, and `status` tools
- `qmd update && qmd embed` keeps the index current (fast incremental refresh)

---

### Cass — Agent Session History Search

[cass](https://github.com/dicklesworthstone/coding_agent_session_search)

Full-text search over past agent session transcripts. Useful for recovering context from previous sessions.

- Built once with `cass index --full`; a scheduled background job keeps it current every 30 minutes
- Search: `cass search --robot "<topic>"` (the `--robot` flag is required — bare `cass search` launches a blocking TUI)

---

### RTK — Token Compression Proxy

[rtk](https://github.com/rtk-ai/rtk)

Transparently compresses bash command output before it reaches the LLM.
Installed as an opencode plugin that auto-patches shell commands.

- Zero configuration; works transparently
- Highest ROI for token efficiency — immediate, compounds with all other tools

---

### Caveman — Token-Efficient Communication Mode

[caveman](https://github.com/JuliusBrussee/caveman)

Ultra-compressed communication mode — ~75% token reduction while keeping full technical accuracy.

- Activate: *"caveman mode"*, *"less tokens"*, or `/caveman`
- Intensity levels: `lite`, `full` (default), `ultra`
- Deactivate: *"stop caveman"* or *"normal mode"*

---

### promptfoo — Agent Evaluation Framework

[promptfoo](https://github.com/promptfoo/promptfoo)

Automated quality checks for agent behavior. Tests request classification, plan structure, code review quality, and skill activation.

- Declarative YAML configs with prompts, test cases, and assertions
- `opencode:sdk` provider starts an ephemeral opencode server per eval
- Web UI: `npx -y promptfoo view`

**Commands:** `cd test/eval && npx -y promptfoo eval`, `npx -y promptfoo view`
**Slash command:** `/eval`

---

### Session Capture — Automatic Memory Promotion

An OpenCode plugin that fires after every completed agent turn and on explicit wrap-up.
Promotes session learnings to the vault's `brain/` notes and Ogham automatically.

- Fires after every agent turn; throttled to at most once per 30 minutes
- Say *"wrap up"* for a full capture pass at any time
- Watermark-based — no duplicate entries across concurrent agents

---

### Diff Context — Session-Aware Git Change Summary

An OpenCode plugin that injects a summary of recent git changes (commits + diffstat) on the first bash tool call of each session.

- Automatic — fires on the first bash call
- Reads the session-capture watermark to know which changes are new since the last session
- Budget-capped: max 30 commit lines + 20 diffstat lines

---

### Langfuse — Observability (Optional)

[langfuse](https://langfuse.com)

Self-hosted LLM observability platform. Tracks token usage, latency, cost, and prompt/response pairs.
Enable by setting `LANGFUSE_ENABLED=true` in `.env`.

- Runs as a Docker Compose profile with Postgres, Redis, ClickHouse, and the web app
- Accessible at `http://localhost:17400` after startup

---

### Graphiti — Temporal Knowledge Graph (Optional)

[graphiti](https://github.com/getzep/graphiti)

Temporal knowledge graph backed by Neo4j. Stores entities and relationships with temporal metadata.
Enable by setting `GRAPHITI_ENABLED=true` in `.env`.

- Runs as a Docker Compose profile with Neo4j and the Graphiti API server
- Requires `NEO4J_PASSWORD` and `OPENAI_API_KEY` in `.env`
- Neo4j browser at `http://localhost:17474`, Graphiti API at `http://localhost:17801`

---

## MCP integrations

Beyond Telamon-managed tools, several third-party MCP servers are available to every project:

| MCP Server | Purpose |
|---|---|
| **GitHub** | Issues, PRs, code search, reviews |
| **Chrome DevTools** | Browser inspection and debugging |
| **Playwright** | Browser automation and testing |
| **ast-grep** | Structural code search using AST patterns |
| **Context7** | Library and framework documentation lookup |
| **grep.app** | Code search across public GitHub repositories |
| **Exa** | Web search |
| **git** | Git operations (status, diff, commit, branch) |

---

## Multi-agent system

### Roles

| Agent | Role |
|---|---|
| **telamon** (orchestrator) | Classifies requests, delegates to specialists, leads workflows |
| **architect** | Designs technical plans and ADRs |
| **developer** | Implements plans into production code |
| **tester** | Validates implementations, writes tests |
| **reviewer** | Reviews changesets against plan and conventions |
| **critic** | Audits codebase for inconsistencies and pattern drift |
| **po** (product owner) | Domain expert, backlog grooming, requirements |
| **security** | Security audits, threat modelling, vulnerability assessment |
| **ui-designer** | Visual specs, design tokens, screen layouts |
| **ux-designer** | User flows, interaction specs, state definitions |

### Slash commands

| Command | Purpose |
|---|---|
| `/plan` | Plan a story or feature |
| `/implement` | Implement an approved plan |
| `/story` | Plan and implement end-to-end |
| `/epic` | Break an epic into stories, plan and implement each |
| `/dev` | Delegate a code task to the developer |
| `/test` | Write or run tests |
| `/review` | Review a code changeset |
| `/gh_review` | Review a GitHub pull request |
| `/eval` | Run agent evaluations with promptfoo |
| `/archive` | Archive completed work notes |
| `/caveman` | Toggle token-efficient communication |
| `/vault-audit` | Audit the knowledge vault |

---

## Under the hood: skills library

Telamon ships a library of skills that guide the agent through structured workflows. See [Repository Layout](repository-layout.md) for the full directory structure.

### Memory & context
recall-memories, remember-lessons-learned, remember-task, remember-checkpoint, remember-session, memory-management, thinking, qmd, ogham, obsidian, cass, graphify, repomix

### Development conventions
architecture-rules, explicit-architecture, rest-conventions, create-adr, create-use-case, documentation-rules, git-rules, makefile, testing, testing/promptfoo, php-rules, laravel, message-bus

### Workflow
agent-communication, plan-story, implement-story, epic, plan-implementation, execute-plan, review-plan, review-changeset, review-security, audit-codebase, retrospective, summarize-plan, test-codebase, exception-handling, optimize-instructions, ui-specification, ux-design

### General engineering ([addyosmani/agent-skills](https://github.com/addyosmani/agent-skills))
api-and-interface-design, browser-testing-with-devtools, ci-cd-and-automation, code-review-and-quality, code-simplification, context-engineering, debugging-and-error-recovery, deprecation-and-migration, documentation-and-adrs, frontend-ui-engineering, git-workflow-and-versioning, idea-refine, incremental-implementation, performance-optimization, planning-and-task-breakdown, security-and-hardening, shipping-and-launch, source-driven-development, spec-driven-development, test-driven-development, using-agent-skills
