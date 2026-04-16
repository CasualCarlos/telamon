# ARCHITECTURE

## Product

The way this project works is:

- A developer clones the repo into their local machine
- User runs `make up` to start the ADK 
  - Verifies installation of necessary tools, and installs them if necesary
  - starts postgres, MCPs, etc
- User runs `make init PROJ=path/to/project` to make a project use this ADK
  - Creates `.ai/adk/memory` symlink → `storage/obsidian/<project-name>/` (vault with brain notes and bootstrap context)
  - Creates `.opencode/skills/adk` symlink → `src/skills` (ADK skills available to agents)
  - Creates `.opencode/plugins/adk` symlink → `src/plugins` (ADK plugins)
  - Creates `.ai/adk/adk.ini` with the project name
  - Creates `.ai/adk/secrets` symlink → `storage/secrets/`
  - Creates `opencode.jsonc` symlink → `storage/opencode.jsonc` (or merges into existing)
  - Writes/merges `AGENTS.md` from `src/AGENTS.md`
  - Writes `.opencode/codebase-index.json`
  - Creates `graphify-out/` symlink and installs git hooks
  - Registers QMD collections and runs an initial semantic index
- In the other project, the user starts the coding agent, ie `opencode` and it has access to the adk `skills`, `plugins`, `memory`, and shared `opencode.jsonc` config

## Priority Order

1. Security
2. Extensibility
3. Feature growth
4. Determinism
5. Stability

## Project structure

```
- .ai/          # ai context
- bin/          # binaries and executable scripts
- scripts/      # shell scripts 
```
