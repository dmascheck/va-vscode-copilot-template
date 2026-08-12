---
agent: agent
description: Audit project health. Delegates to @auditor agent for context files, env config, dependencies, git state. READ-ONLY.
---

# Health Check

**Purpose:** Audit project health and report issues. Read-only.

Delegate to `@auditor` agent. The auditor checks:
1. Context files (presence, size, staleness)
2. Environment config (.env.project, Azure Gov settings, compliance flags)
3. Git health (branch, sync status, uncommitted changes)
4. Dependencies (installed, outdated, vulnerabilities)
5. VA compliance (FedRAMP level set, Gov region configured, no commercial endpoints)
