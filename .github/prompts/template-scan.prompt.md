---
agent: agent
description: Deep scan template project and auto-update TEMPLATE_GUIDE.md. Only runs when TEMPLATE_GUIDE.md exists in the project root.
---

# Template Scan

**Purpose:** Scan all template components and update TEMPLATE_GUIDE.md with any changes found.

**Guard:** Only run if `TEMPLATE_GUIDE.md` exists in the project root.

## Steps

1. Read current TEMPLATE_GUIDE.md
2. Scan `.github/prompts/` — count and list all prompts
3. Scan `.github/agents/` — count and list all agents
4. Scan `.github/instructions/` — count and list all instructions
5. Scan `scripts/` — count and list all scripts
6. Scan `.github/context/` — list context files
7. Check version numbers across files
8. Scan `.vscode/` config files
9. Generate diff report (documented vs actual)
10. Auto-update TEMPLATE_GUIDE.md with changes
11. Report what changed
