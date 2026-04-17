---
name: telamon.remember_task
description: "Record what was learned after completing a task. Review discoveries, update memories.md with structured lessons, store in Ogham. Use after finishing a task, fixing a non-trivial bug, or completing a planning round."
---

# Remember Task

Run after finishing a task, fixing a non-trivial bug, completing a planning round, or delivering any meaningful output — whether part of a formal workflow or standalone.

## 1. Review what was learned

Ask yourself:
- Did I discover a reusable pattern?
- Did I hit a trap or constraint others should know?
- Was a decision made (or clarified) during this work?
- Did the human stakeholder provide new context?

## 2. Update memories.md

Append new lessons to `.ai/telamon/memory/brain/memories.md`. One entry per lesson — do not bundle multiple takeaways.

Use the M-XXX-NNN entry format, categories, and quality rules from the `telamon.memory_management` skill (section 5).

## 3. Store in Ogham

```
ogham store "lesson: <one-line summary of what was learned>"
```

## 4. Pruning

When memories.md exceeds 100 entries, follow the pruning rules in the `telamon.memory_management` skill (section 5).
