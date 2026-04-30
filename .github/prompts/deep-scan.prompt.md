---
agent: agent
description: Full project scan. Delegates to @scanner agent for CODE_MAP.md regeneration and API_REFERENCE.md updates.
---

# Deep Scan

**Purpose:** Full project scan to regenerate code map and API reference.

Delegate to `@scanner` agent for execution. The scanner will:
1. Discover all source files, entry points, and directory structure
2. Regenerate `.github/context/CODE_MAP.md`
3. Update `docs/API_REFERENCE.md` if FastAPI routers exist
