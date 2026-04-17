---
name: telamon.remember_checkpoint
description: "Save a checkpoint before context overflow. Persist working state to Ogham, promote learnings to brain/ notes, compact, then recall. Use when context nears limit, responses slow down, or opencode warns of compaction."
---

# Remember Checkpoint

Triggers: repetition in responses, slow output, opencode warns of compaction.

## Procedure

1. **Checkpoint**: Use the `telamon.ogham` skill to store a checkpoint.
2. **Promote**: Save any new learnings to the relevant brain/ note (see `telamon.memory_management` skill, section 2 for routing)
3. **Compact**: Run `/compact` in opencode
4. **Recall**: Use the `telamon.ogham` skill to search for the checkpoint, re-read relevant brain/ notes to re-anchor goals and use the `telamon-recall_memories` skill to gather relevant context.
