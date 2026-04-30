---
agent: agent
description: "Mid-session context save OR refresh. Run every 30-45 min, or when Copilot seems to be drifting."
---

# Sync Context

**Purpose:** Save current state mid-session to prevent context loss.

## Steps

1. Update `.github/context/PROJECT_CONTEXT.md` with current state
2. Update `.github/context/TODO.md` — mark completed, add new
3. Write checkpoint to `Logs/sessions/`
4. Git commit context changes

If user says "just refresh" → read-only mode (re-read all context files, no writes).
