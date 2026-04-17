---
name: telamon.ogham
description: "Ogham semantic agent memory -- profile switching, storing, and searching. Use when storing decisions, patterns, bugs, lessons, or checkpoints in Ogham, searching past knowledge, or switching project profiles. Triggers: 'ogham store', 'ogham search', 'switch profile', 'remember this'."
allowed-tools: ogham_*
---

# Ogham -- Semantic Agent Memory

Persistent vector memory for decisions, patterns, bugs, lessons, and checkpoints. Backed by Postgres + pgvector with Ollama embeddings.

## When to Apply

- Switching Ogham profile at session start or when changing projects
- Storing decisions, bugs, patterns, rules, lessons, or checkpoints
- Searching past knowledge by meaning
- Recalling checkpoints after context compaction

## 1. Profile Management

Switch profile at session start (one profile per project):

```
ogham use <project-name>
```

When switching projects mid-session:

```
ogham use <new-project-name>
```

## 2. Searching

Search by meaning (semantic + keyword hybrid):

```
ogham search "<keywords or question>"
```

Common searches:
- Session start: `ogham search "<current task or recent topic>"`
- After compaction: `ogham search "checkpoint"`
- Past decisions: `ogham search "decision <topic>"`

## 3. Storing

Store knowledge the moment it arises. One fact per call -- do not bundle.

| What happened                        | Command                                                      |
|--------------------------------------|--------------------------------------------------------------|
| Architectural or product decision    | `ogham store "decision: X over Y because Z"`                 |
| Human stakeholder answers a question | `ogham store "decision: <Q> -> <A>"`                         |
| New rule given by stakeholder        | `ogham store "rule: <rule>"`                                 |
| Bug fixed (non-trivial)              | `ogham store "bug: <desc and fix>"`                          |
| Pattern established                  | `ogham store "pattern: <desc>"`                              |
| Lesson learned                       | `ogham store "lesson: <one-line summary>"`                   |
| Checkpoint before compaction         | `ogham store "checkpoint: <task> -- done: <X> -- next: <Y>"` |

## 4. What NOT to Store

- Secrets, API keys, passwords
- Raw command output or logs
- Trivial edits or routine operations
- Information already captured in brain/ notes (avoid duplication)

See the `telamon.memory_management` skill, section 4 (Never write) for the full list.
