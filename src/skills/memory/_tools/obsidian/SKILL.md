---
name: telamon.obsidian
description: "Obsidian MCP tool usage — searching, reading, writing, and linking vault notes. Use when interacting with the Obsidian vault via MCP tools. Triggers: search_vault, read_note, patch_note, write_note, wikilink."
allowed-tools: obsidian_*
---

# Obsidian — Vault Tool Usage

How to interact with the Obsidian vault via MCP tools. For vault structure, routing, and content rules, see the `telamon.memory_management` skill.

## When to Apply

- Searching vault notes via Obsidian MCP
- Reading or writing vault notes via Obsidian MCP
- Creating or updating notes with frontmatter and wikilinks

## 1. Searching

Always search before reading non-brain files. Scope every search to the project subfolder. Discard results with relevance score < 0.6.

```
OK  search_vault("auth migration", path="my-project/")
BAD search_vault("auth migration")
BAD list_files("/")
BAD read_note("index.md")
```

## 2. Reading

- **brain/ files**: read directly — always relevant, no search needed
- **All other files**: search first, then read top results
- **bootstrap/ files**: loaded automatically at session start — do not re-read

## 3. Writing

### Creating notes
1. Use YAML frontmatter: `date`, `description` (~150 chars), `tags`, `status`, `project`
2. Link to at least one existing note via `[[wikilink]]` — an orphan note is a bug

### Updating existing notes
- Use `patch_note` (not `write_note`) to preserve frontmatter
- Add `updated: <date>` to frontmatter

## 4. Wikilinks

Every new vault note must contain at least one `[[wikilink]]` to an existing note. Verify after creating or updating notes.
