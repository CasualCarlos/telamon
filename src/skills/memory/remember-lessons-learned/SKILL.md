---
name: telamon.remember_lessons_learned
description: "Capture knowledge as you work. Save decisions, patterns, bugs, and rules to Ogham and brain/ notes the moment they arise. Use continuously during work — do not defer to end of session."
---

# Remember Lessons Learned

As you work, capture knowledge the moment it arises. Do not defer to end of session.

## What to save and where

| What happened | Ogham (use `telamon.ogham` skill) | Brain/ file |
|---|---|---|
| Decision made (architectural or product) | Store as decision | Append to `brain/key_decisions.md` |
| Human stakeholder answers a question | Store as decision | Append to `brain/key_decisions.md` |
| New rule given by stakeholder | Store as rule | Append to `brain/key_decisions.md` |
| Bug fixed (non-trivial) | Store as bug | Append to `brain/gotchas.md` if recurring |
| Pattern established | Store as pattern | Append to `brain/patterns.md` |
| Graphiti enabled? | Also save via Graphiti `add_episode` | -- |

## What NOT to save

See the `telamon.memory_management` skill, section 4 (Never write) for the full list. Key rule: never save secrets, command output, or trivial edits.
