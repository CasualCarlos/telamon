---
name: telamon.memory_management
description: "Canonical rules for the .ai/telamon/memory/ vault: folder structure, routing, retrieval, writing, entry format, thinking/ lifecycle, pruning. Use when reading, writing, or organizing vault .md files. Triggers: any vault operation, 'check the docs', 'update the wiki', referencing structure, routing, or quality rules."
---

# Memory Management — Vault Structure & Rules

Canonical reference for all `.ai/telamon/memory/` vault operations. Other memory skills reference this skill for structure, routing, and quality rules.

## When to Apply

- When reading, writing, or organizing files in `.ai/telamon/memory/`
- When another memory skill references vault rules
- When auditing vault structure or brain note quality
- When resolving where to save a piece of knowledge

## 1. Vault Structure

```
.ai/telamon/memory/
  bootstrap/                 <- always-on context (loaded like AGENTS.md)
  brain/
    memories.md              <- knowledge index -- READ THIS FIRST
    key_decisions.md         <- architectural + product decisions, stakeholder answers
    patterns.md              <- established codebase patterns
    gotchas.md               <- known traps and constraints
  work/
    active/                  <- in-progress work notes (1-3 files max)
    archive/YYYY/            <- completed work notes by year
    incidents/               <- incident docs
  reference/                 <- architecture maps, flow docs, codebase knowledge
  thinking/                  <- scratchpad for drafts (promote or delete)
```

## 2. Routing Table

| Content | Destination |
|---|---|
| Agent bootstrap instructions (always-on) | `bootstrap/` |
| Architectural or product decision + rationale | `brain/key_decisions.md` |
| Human stakeholder answer to a project question | `brain/key_decisions.md` |
| New rule from stakeholder | `brain/key_decisions.md` |
| Established codebase pattern | `brain/patterns.md` |
| Trap, constraint, or recurring bug | `brain/gotchas.md` |
| Categorized lesson learned | `brain/memories.md` (M-XXX-NNN format, see section 5) |
| In-progress work note | `work/active/` |
| Completed work note | `work/archive/YYYY/` |
| Incident doc | `work/incidents/YYYY-MM-DD-<slug>.md` |
| Architecture map or flow doc | `reference/` |
| Draft or reasoning scratchpad | `thinking/` (promote or delete, see section 6) |
| Partial-progress checkpoint | `thinking/YYYY-MM-DD-HH:MM:SS-<task>-partial.md` |

**Routing rules:**
- Append -- never replace existing content
- One entry per insight
- Include dates in entries
- When writing to `brain/key_decisions.md` and Graphiti is enabled (`telamon-graphiti` container running): also create a Graphiti entity via `add_episode`

## 3. Retrieval Rules

### R1 -- bootstrap/ is always in context
Files in `bootstrap/` load automatically at session start. Do not search or re-read them.

### R2 -- Direct reads for brain/ files
brain/ files are small and always relevant -- read directly, no search needed:
- `brain/memories.md` -- read at session start
- `brain/key_decisions.md` -- read before architecture work or stakeholder answer lookup
- `brain/patterns.md` -- read before writing new code
- `brain/gotchas.md` -- read before touching known problem areas

### R3 -- Search before read (non-brain files)
Never call `read_note` or `list_files` without searching first. Exception: user explicitly names a file.
```
OK  search_vault("auth migration", path="my-project/")
BAD list_files("/")
BAD read_note("index.md")
```

### R4 -- Max 3 non-brain notes per task
Pick top 3 by relevance. Tell the user if truncated ("Found 7 notes, reading top 3").

### R5 -- Scope searches to project
```
OK  search_vault("auth migration", path="my-project/")
BAD search_vault("auth migration")
```

### R6 -- Score threshold
Discard results with relevance score < 0.6. Say "No relevant notes found" and use Ogham instead.

## 4. Writing Rules

### Creating notes
1. Use YAML frontmatter: `date`, `description` (~150 chars), `tags`, `status`, `project`
2. Place in the correct subfolder per the routing table (section 2)
3. Link to at least one existing note via `[[wikilink]]` -- an orphan note is a bug

### Updating existing notes
- Use `patch_note` (not `write_note`) to preserve frontmatter
- Add `updated: <date>` to frontmatter

### Never write
- Secrets, API keys, passwords
- Content duplicating what is already in Ogham
- Files in the vault root (only subfolders)
- Agent instructions outside `bootstrap/` expecting auto-load

## 5. Memory Entry Format (memories.md)

### Entry template

```markdown
### M-<CATEGORY>-NNN: <title>
- **Date**: YYYY-MM-DD
- **Context**: What triggered this lesson.
- **Lesson**: The reusable takeaway.
- **Scope**: Where this applies (component, layer, or project-wide).
- **Status**: ACTIVE
```

### Categories

| Category | Prefix | Example |
|---|---|---|
| Architecture Decisions | `M-ARCH` | Layer boundaries, dependency rules |
| Testing Patterns | `M-TEST` | Test structure, tooling, strategies |
| Domain Knowledge | `M-DOMAIN` | Business rules, domain semantics |
| Anti-Patterns | `M-ANTI` | Approaches that failed -- what to do instead |
| Workflow Lessons | `M-FLOW` | Agent delegation, communication, tooling |

Number sequentially within each category. Check existing entries first.

### Entry quality rules
- **Specific, not generic** -- "Always pass `--no-interaction` to Artisan" not "Be careful with CLI commands"
- **Include context** -- future agents need to understand *why*
- **Scope it** -- a lesson about the Invoice component must say so

### Pruning (when memories.md exceeds 100 entries)
- Mark entries as `SUPERSEDED by M-XXX-NNN` when a newer entry replaces them
- Keep superseded entries for one more session before removing
- Review entries older than 6 months for continued relevance
- Only the PO or human stakeholder may remove entries

## 6. Thinking/ Lifecycle

### Promote or discard
For each file in `thinking/`:
- Contains a reusable lesson -> promote to brain/, then **delete**
- Completed work -> **delete**
- Still live WIP -> keep; rename to `partial-<task>-YYYY-MM-DD.md` if not descriptive

### Hygiene
- Flag any `thinking/` file older than 7 days for user review
- Partial-progress notes use: `YYYY-MM-DD-HH:MM:SS-<task>-partial.md`

### Watermark
Session capture tracks progress via `.ai/telamon/memory/thinking/.last-capture-<worktree-dirname>.json`. Only content after the watermark timestamp needs processing.

## 7. Brain Note Quality Criteria

| File | Good entry has |
|---|---|
| `key_decisions.md` | Decision + rationale (not just the decision) |
| `patterns.md` | Actionable, specific pattern with when to apply |
| `gotchas.md` | Reproducible problem + fix or workaround |
| `memories.md` | M-XXX-NNN format, recent context reflects last sessions |

## 8. Memory Tiers (reference)

| Tier | Store | Content | Writer |
|---|---|---|---|
| Working | AGENTS.md + session context | Active goals, current task state | Human + agent at session start |
| Episodic | Ogham + cass | Past actions, bugs, patterns, sessions | Agent during/after sessions |
| Long-term | brain/ notes | Architectural decisions, domain knowledge, patterns, gotchas | Agent at wrap-up, human for strategy |
