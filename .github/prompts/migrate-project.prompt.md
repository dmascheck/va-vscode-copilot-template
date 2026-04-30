---
description: "Guided workflow to convert a Windsurf project to VS Code Copilot project structure"
---

# Migrate Project (Windsurf → VS Code)

**Purpose:** Convert a Windsurf-structured project to use VS Code Copilot conventions.

## Mapping

| Windsurf | VS Code |
|----------|---------|
| `.windsurf/context/` | `.github/context/` |
| `.windsurf/rules/` | `.github/instructions/` |
| Mode skills | `.github/agents/` |
| `/command` | `#command` (prompts) |
| `.windsurf/hooks.json` | `.vscode/hooks.json` |

## Steps

1. Scan existing project for Windsurf artifacts
2. Copy context files to `.github/context/`
3. Convert rules to instruction format
4. Create agent files from mode skills
5. Update references in documentation
6. Verify all files migrated
