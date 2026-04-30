---
agent: agent
description: Quick project snapshot — state, tasks, recent changes, blockers. One-screen dashboard. READ-ONLY.
---

# Status

**Purpose:** Quick dashboard of project state. Read-only — no file modifications.

## Steps

1. Read `PROJECT_CONTEXT.md`, `TODO.md`, `NEXT_SESSION.md`
2. Run `git log --oneline -5` and `git status`
3. Check `.env.project` for infrastructure state

## Output

```
📊 PROJECT STATUS: {project name}
🔧 Branch: {branch} · {clean/dirty}
📋 TODO: {N open} / {N done} / {N backlog}
☁️ Azure Gov: {region} · {resource count}
🛡️ Compliance: FedRAMP {level} · PHI: {yes/no}
🎯 Current Focus: {from NEXT_SESSION.md}
⚠️ Blockers: {list or "none"}
```
