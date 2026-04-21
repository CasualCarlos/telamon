---
layout: page
title: Commands
description: All available telamon CLI commands and make targets.
nav_section: docs
---

## CLI commands

After installing, the `telamon` command is available system-wide from any directory.

| Command | Description |
|---|---|
| `telamon up` | Install host tools + start Docker services |
| `telamon down` | Stop Docker services |
| `telamon restart` | Stop then start |
| `telamon status` | Quick installation status |
| `telamon doctor` | Comprehensive health check (connectivity, config, secrets) |
| `telamon update` | Upgrade all Telamon-managed tools |
| `telamon init [path]` | Initialise a project (default: current directory) |
| `telamon reset [path]` | Remove project wiring, keep storage data |
| `telamon purge [path]` | Remove project wiring **and** storage data |
| `telamon uninstall` | Completely remove Telamon (destructive) |
| `telamon help` | Show usage help |

`init`, `reset`, and `purge` accept an optional path. If omitted, they use the current directory. Relative paths are resolved correctly:

```bash
cd ~/my-project && telamon init          # initialises ~/my-project
telamon init ~/my-project                # same result, from anywhere
telamon init ../other-project            # relative path works too
```

---

## Under the hood: make targets

The `telamon` CLI is a thin wrapper around `make` targets. When running from the Telamon directory, you can use `make` directly:

| Target | Description |
|---|---|
| `make up` | Install host tools + start Docker services |
| `make down` | Stop Docker services |
| `make restart` | Stop then start |
| `make status` | Quick installation status |
| `make doctor` | Comprehensive health check |
| `make update` | Upgrade all tools |
| `make init PROJ=<path>` | Initialise a project |
| `make reset PROJ=<path>` | Remove project wiring, keep storage |
| `make purge PROJ=<path>` | Remove wiring and storage |
| `make uninstall` | Completely remove Telamon |
| `make test` | Run the full test suite |

> `make init`, `make reset`, and `make purge` require the `PROJ=` argument. Use the `telamon` CLI for the default-to-cwd convenience.

---

## CLI installation

The `telamon` CLI is installed automatically as part of `make up`. It creates:

- **Symlink**: `~/.local/bin/telamon` → `<telamon-root>/bin/telamon`
- **Linux menu entry**: `~/.local/share/applications/telamon.desktop`
- **macOS app**: `~/Applications/Telamon.app`

The CLI resolves its own symlink chain to find the Telamon root, so it works from any location.
